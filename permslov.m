
contrnames = fieldnames(CCN.contr.contrs);
statdir = sprintf('%s/permstat', ...
    CCN.root_dir);

mskname = fileprep(CCN.model.mask, 'r');
sname = '/data00/jmcarp/tools/templates/MNI152_T1_1mm.nii';

slices = -25 : 15 : 65;
erodim = 5;

for contridx = 1 : length(contrnames)
    
    contrname = contrnames{contridx};
    
    for stepidx = 1 : length(env.allsteps)

        stepname = env.allsteps{stepidx};

        % Check step values
        if ismember(stepname, env.procsteps)
            stepvals = fieldnames(p.proc.(stepname));
        elseif ismember(stepname, env.modelsteps)
            stepvals = fieldnames(p.model.(stepname));
        end
        nsteps = length(stepvals);
        if nsteps == 1
            continue
        end
        
        fname = sprintf('%s/%s/l2/md_%s.img', ...
            statdir, contrname, stepname);
        spm_reslice({CCN.norm.hrtemp fname});
        rfname = fileprep(fname, 'r');
        
        savdir = sprintf('%s/figs/%s', ...
            CCN.root_dir, contrname);
        if ~exist(savdir, 'dir')
            mkdir(savdir);
        end

        figfile = sprintf('%s/figs/%s/md_slover_%s', ...
            CCN.root_dir, contrname, stepname);
        
        so = modslov(rfname, sname, mskname, ...
            slices, figfile, erodim);
        
    end
    
    % 
    for stat = { 'permvar' 'permmean' 'permvib'}

        fname = sprintf('%s/%s/l2/%s.img', ...
            statdir, contrname, char(stat));
        spm_reslice({CCN.norm.hrtemp fname});
        rfname = fileprep(fname, 'r');
        
        figfile = sprintf('%s/figs/%s/stat_slover_%s', ...
            CCN.root_dir, contrname, char(stat));
        
        so = modslov(rfname, sname, mskname, ...
            slices, figfile, erodim);
        
    end
    
end