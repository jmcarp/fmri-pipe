function plotfx

global CCN;
if isempty(CCN)
    batchpar_008;
end

p = getpermlist;
env = getpenv(p, CCN);

contrnames = fieldnames(CCN.contr.contrs);
statdir = sprintf('%s/permstat', ...
    CCN.root_dir);

slices = -25 : 15 : 75;
erodim = 5;

for contridx = 1 : length(contrnames)
    
    contrname = contrnames{contridx};
    
    for stepidx = 1 : length(env.allsteps)

        step = env.allsteps{stepidx};

        for levidx = 2%1 : 2
            
            fname = sprintf('%s/%s/l%d/md_%s.img', ...
                statdir, contrname, levidx, step);
            if ~exist(fname, 'file')
                continue
            end
            
            savdir = sprintf('%s/figs/%s/l%d', ...
                CCN.root_dir, contrname, levidx);
            if ~exist(savdir, 'dir')
                mkdir(savdir);
            end
            
            outname = sprintf('%s/md_slover_%s', ...
                savdir, step);
            
            so = permso(fname, CCN.model.mask, CCN.norm.hrtemp, ...
                slices, erodim, outname);
            
%             rfname = fileprep(fname, 'r');
% %             spm_reslice({CCN.model.mask fname});
%             spm_reslice({CCN.norm.hrtemp fname});
%             rfvol = spm_vol(rfname);
%             rfimg = spm_read_vols(rfvol);
%             se = strel('disk', 5);
%             emsk = imerode(mskimg, se);
%             rfimg(emsk == 0) = nan;
%             spm_write_vol(rfvol, rfimg);
%             sname = '/data00/jmcarp/tools/templates/MNI152_T1_1mm.nii';
% %             sname = '/data00/jmcarp/tools/spm8/canonical/single_subj_T1.nii';
%             
% %             so = slover(spm_vol(char({rfname sname})));
% %             so.img(1).type = 'truecolor';
% %             so.img(1).cmap = jet;
% %             % so.img(2).type = 'truecolor';
% %             so.img(2).range = [78 7616];
% % %             so.img(2).range = [ 0.0078 0.5625 ];
% %             so.slices = -25 : 15 : 75;
% %             so.cbar = 1;
% %             so.printstr = 'print -dpsc -painters -noui -r300';
% % 
% %             so = paint(so);
% %             
% %             savdir = sprintf('%s/figs/%s/l%d', ...
% %                 CCN.root_dir, contrname, levidx);
% %             if ~exist(savdir, 'dir')
% %                 mkdir(savdir);
% %             end
% %             
% %             figfile = sprintf('%s/figs/%s/l%d/md_slover_%s', ...
% %                 CCN.root_dir, contrname, levidx, step);
% %             so.printstr = 'print -dpdf -painters -noui -r1200';
% %             so.printfile = figfile;
% %             print_fig(so);
            
        end

    end

end

return

%%

for levidx = 2%1 : 2

    for contridx = 1 : length(contrnames)

        contrname = contrnames{contridx};

    %     for stat = { 'permmean' 'permrng' 'l1vib' 'l1avg' }
        for stat = { 'permvar' 'permmean' 'permvib'}

            fname = sprintf('%s/%s/l%d/%s.img', ...
                statdir, contrname, levidx, char(stat));
            sname = '/data00/jmcarp/tools/spm8/canonical/single_subj_T1.nii';

            so = slover(spm_vol(char({fname sname})));
            so.img(1).type = 'truecolor';
            so.img(1).cmap = jet;
            % so.img(2).type = 'truecolor';
            so.slices = -25 : 10 : 75;
            so.cbar = 1;

            so = paint(so);

    %         figfile = sprintf('%s/figs/%s/l%d/stat_slover_%s.png', ...
    %             CCN.root_dir, char(stat));
            figfile = sprintf('%s/figs/%s/l%d/stat_slover_%s', ...
                CCN.root_dir, contrname, levidx, char(stat));

            so.printstr = 'print -dpdf -painters -noui -r600';
            so.printfile = figfile;
            print_fig(so);

        end

    end

end