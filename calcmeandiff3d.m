function [mdiff mcorr] = calcmeandiff3d(vols, imgs, ...
    p, env, optmat, apptxt, dosav, savdir)

% Check save directory
if nargin < 8
    savdir = sprintf('%s/%s', env.statdir, apptxt);
    if dosav && ~exist(savdir, 'dir')
        mkdir(savdir);
    end
end

% Get permutation count
nvols = length(vols);

% Initialize mean difference
imgdim = vols(1).dim;
mdiff = nan(imgdim(1), imgdim(2), imgdim(3), ...
    length(env.allsteps));

for stepidx = 1 : length(env.allsteps)
    
    stepname = env.allsteps{stepidx};
    
    % Check step values
    if ismember(stepname, env.procsteps)
        stepvals = fieldnames(p.proc.(stepname));
    elseif ismember(stepname, env.modelsteps)
        stepvals = fieldnames(p.model.(stepname));
    end
%     stepvals = unique(optmat(:, stepidx));
    nsteps = length(stepvals);
    if nsteps == 1
        continue
    end
    
    % Print step
    fprintf('\t\tWorking on option %s...\n', ...
        env.allsteps{stepidx});
    
    % Initialize IDs
    ids = nan(nsteps, nvols / nsteps);
    
    % Get IDs
    for validx = 1 : length(stepvals)
        val = stepvals{validx};
        ids(validx, :) = find(ismember(optmat(:, stepidx), val));
    end
    
    % Get mean difference
    [d c] = meandiff3d(imgs, ids);
    mdiff(:, :, :, stepidx) = d;
    mcorr(stepidx) = c;
    
%     [dmd dmc] = diffmean3d(imgs, ids);
%     dmean{stepidx} = dmd;
%     dmcorr{stepidx} = dmc;
    
    % Save results
    if dosav
        
        mdvol = vols(1);
        mdvol.fname = sprintf('%s/md_%s.img', ...
            savdir, stepname);
        spm_write_vol(mdvol, squeeze(mdiff(:, :, :, stepidx)));
        
%         ct = 0;
%         for dmidx1 = 1 : length(stepvals)
%             for dmidx2 = dmidx1 + 1 : length(stepvals)
%                 ct = ct + 1;
%                 dmvol = vols(1);
%                 dmvol.fname = sprintf('%s/dm_%s_%s_%s.img', ...
%                     savdir, stepname, ...
%                     stepvals{dmidx1}, stepvals{dmidx2});
%                 spm_write_vol(dmvol, dmean{stepidx}{ct});
%             end
%         end
        
    end
    
end