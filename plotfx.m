function plotfx

global CCN;
if isempty(CCN)
    batchpar_008;
end

p = getpermlist;
env = getpenv(p, CCN);

contrnames = fieldnames(CCN.contr.contrs);
statnames = { 'permvar' 'permmean' 'permrng' };
thrsumnames = { 'prop' 'disagree' };
thrnames = { 'as_pe2' 'as_pe3' 'as_pe4' 'fdr' 'fwe' '' };

statdir = sprintf('%s/permstat', ...
    CCN.root_dir);

mask = '/data00/jmcarp/tools/spm8/apriori/brainmask_th125.nii';
sname = '/data00/jmcarp/tools/templates/MNI152_T1_1mm.nii';
slices = -25 : 15 : 75;
erodim = 5;

l1dirs = {};
% l1dirs = { 'grp' };
% l1dirs = [ 'grp' CCN.subjs ];

doreslice = true;
% doreslice = false;

for contridx = 1 : length(contrnames)
    
    % Get contrast name
    contrname = contrnames{contridx};
    
    % Check second-level directories
    l2savdir = sprintf('%s/figs/%s/l2', ...
        CCN.root_dir, contrname);
    if ~exist(l2savdir, 'dir')
        mkdir(l2savdir);
    end
    
%     % Check first-level directories
%     l1savdir = sprintf('%s/figs/%s/l1', ...
%         CCN.root_dir, contrname);
%     for diridx = 1 : length(l1dirs)
%         l1dir = sprintf('%s/%s', ...
%             l1savdir, l1dirs{diridx});
%         if ~exist(l1dir, 'dir')
%             mkdir(l1dir);
%         end
%     end
    
    % Plot threshold images
    for thrsumidx = 1 : length(thrsumnames)
        
        thrsumname = thrsumnames{thrsumidx};
        if strcmp(thrsumname, 'prop')
            zlim = [0 1];
        else
            zlim = [0 0.5];
        end
        
        for thridx = 1 : length(thrnames)
            
            thrname = thrnames{thridx};
            if ~strcmp(thrname, '')
                thrname = ['_' thrname];
            end
            
            fname = sprintf('%s/%s/l2/sig_%s%s.img', ...
                statdir, contrname, thrsumname, thrname);
            if ~exist(fname, 'file')
                continue
            end
            
            outname = sprintf('%s/sig_%s%s', ...
                l2savdir, thrsumname, thrname);
            
            [~, doreslice] = permso(fname, mask, sname, ...
                slices, erodim, outname, zlim, doreslice);
            
        end
    
    end
    
    % Plot summary statistics
    for statidx = 1 : length(statnames)

        stat = statnames{statidx};

        fname = sprintf('%s/%s/l2/%s.img', ...
            statdir, contrname, stat);
        if ~exist(fname, 'file')
            continue
        end

        outname = sprintf('%s/stat_slover_%s', ...
            l2savdir, stat);

        [~, doreslice] = permso(fname, mask, sname, ...
            slices, erodim, outname, false, doreslice);
        
        for diridx = 1 : length(l1dirs)
            
            l1dir = l1dirs{diridx};
            
            fname = sprintf('%s/%s/l1/%s/%s.img', ...
                statdir, contrname, l1dir, stat);
            if ~exist(fname, 'file')
                continue
            end
            
            outname = sprintf('%s/%s/stat_slover_%s', ...
                l1savdir, l1dir, stat);
            
            [~, doreslice] = permso(fname, mask, sname, ...
                slices, erodim, outname, false, doreslice);
            
        end
        
    end
    
    % Plot mean difference statistics
    for stepidx = 1 : length(env.allsteps)

        step = env.allsteps{stepidx};

        fname = sprintf('%s/%s/l2/md_%s.img', ...
            statdir, contrname, step);
        if ~exist(fname, 'file')
            continue
        end
        
        outname = sprintf('%s/md_slover_%s', ...
            l2savdir, step);

        [~, doreslice] = permso(fname, mask, sname, ...
            slices, erodim, outname, false, doreslice);

        for diridx = 1 : length(l1dirs)
            
            l1dir = l1dirs{diridx};
            
            fname = sprintf('%s/%s/l1/%s/md_%s.img', ...
                statdir, contrname, l1dir, step);
            if ~exist(fname, 'file')
                continue
            end
            
            outname = sprintf('%s/%s/md_slover_%s', ...
                l1savdir, l1dir, step);
            
            [~, doreslice] = permso(fname, mask, sname, ...
                slices, erodim, outname, false, doreslice);
            
        end
        
    end
    
end