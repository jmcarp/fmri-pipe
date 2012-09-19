function md3d = calcmeandiff3d(env, optmat, statdir, lev)

savdir = sprintf('%s/%s', statdir, lev);
if ~exist(savdir, 'dir')
    mkdir(savdir);
end

for optidx = 1 : length(env.allsteps)
    
    fprintf('Working on option %s...', ...
        env.allsteps{optidx});
    
    optvals = unique(optmat(:, optidx));
    ids = [];
    
    for validx = 1 : length(optvals)
        
        ids = [ids ; find(ismember(optmat(:, optidx), val))'];
        
    end
    
    md3d(:, :, :, optidx) = meandiff3d(imgs, ids);
    
    mdvol = vols(1);
    mdvol.fname = sprintf('%s/md_%s.img', savdir, env.allsteps{optidx});
    spm_write_vol(mdvol, squeeze(md3d(:, :, :, optidx)));
    
end