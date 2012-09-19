function [gscorr gscorrmd] = grpsubcorr

global CCN;
if isempty(CCN)
    batchpar_008;
end

p = getpermlist;
env = getpenv(p, CCN);

contrnames = fieldnames(CCN.contr.contrs);

statdir = sprintf('%s/permstat', ...
    CCN.root_dir);

for contridx = 1 : length(contrnames)
    
    % Get contrast name
    contrname = contrnames{contridx};
    
    grprngname = sprintf('%s/%s/l2/permrng.img', ...
        statdir, contrname);
    grprngvol = spm_vol(grprngname);
    grprngimg = spm_read_vols(grprngvol);
    
    subrngname = sprintf('%s/%s/l1/grp/permrng.img', ...
        statdir, contrname);
    subrngvol = spm_vol(subrngname);
    subrngimg = spm_read_vols(subrngvol);
    
    incvox = ~isnan(grprngimg);
    
    gscorr(contridx) = corr( ...
        grprngimg(incvox), subrngimg(incvox));
    
    % 
    mdidx = 2;
    stepct = 1;
    for stepidx = 1 : length(env.allsteps)
        
        step = env.allsteps{stepidx};
        
        grpmdname = sprintf('%s/%s/l2/md_%s.img', ...
            statdir, contrname, step);
        if ~exist(grpmdname, 'file')
            continue
        end
        grpmdvol = spm_vol(grpmdname);
        grpmdimg = spm_read_vols(grpmdvol);
        
        submdname = sprintf('%s/%s/l1/grp/md_%s.img', ...
            statdir, contrname, step);
        submdvol = spm_vol(submdname);
        submdimg = spm_read_vols(submdvol);
        
        gscorrmd(contridx, mdidx) = corr( ...
            grpmdimg(incvox), submdimg(incvox));
        mdidx = mdidx + 1;
        
        stepct = stepct + 1;
        
    end
    
end