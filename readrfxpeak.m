function peak = readrfxpeak

global CCN;
if isempty(CCN)
    batchpar_008;
end

p = getpermlist;
env = getpenv(p, CCN);

[optlist optmat] = reclist(1, {}, {}, {}, p, env, CCN);
[optlist optmat contrlist p] = addcontr(optlist, optmat, p, env);

contrnames = fieldnames(CCN.contr.contrs);

% 
masknames = { 'rifc' 'raud' };
maskdir = sprintf('%s/roimask', CCN.root_dir);
maskfiles = cell(length(masknames), 1);
for maskidx = 1 : length(masknames)
    
    maskname = masknames{maskidx};
    maskfile = sprintf('%s/%s.nii', maskdir, maskname);
    maskfiles{maskidx} = maskfile;
    
    dilname = mridilate(maskfile, 2.5, 0.5, 'dil');
    
    surfname = fileprep(dilname, 'surf_');
    
    lhname = chext(surfname, '_lh.nii');
    surfcmd = sprintf(...
        'mri_vol2surf --src %s --o %s --regheader fsaverage --hemi lh', ...
        dilname, lhname);
    system(surfcmd);
    
    rhname = chext(surfname, '_rh.nii');
    surfcmd = sprintf(...
        'mri_vol2surf --src %s --o %s --regheader fsaverage --hemi rh', ...
        dilname, rhname);
    system(surfcmd);
    
end

% Initialize peaks
peak = struct();

for contridx = 1 : length(contrnames)
    
    % Get contrast name
    contrname = contrnames{contridx};
    fprintf('Working on contrast %s...\n', contrname);
    
    % Initialize progress bar
    fprintf('Progress:       ');
    
    %
    mmpeak = nan(length(optlist), 2 + length(maskfiles), 3);
    voxpeak = nan(length(optlist), 2 + length(maskfiles), 3);
    labpeak = cell(length(optlist), 2, 6);
    
    for optidx = 1 : length(optlist)
        
        opts = optlist{optidx};
        contrtype = contrlist{optidx};
        
        % Get SPM.mat
        spmdir = sprintf('%s/permrfx/%s/%s', ...
            CCN.root_dir, opts, contrname);
        spmmat = sprintf('%s/SPM.mat', spmdir);
        
        % Load SPM.mat
        load(spmmat);
        xidx = getxconidx(SPM, contrname, contrtype);
                
        % Get hemisphere peaks
        [mmhem voxhem] = getspmpeak(spmmat, xidx);
        
        % Get mask peaks
        [mmmsk voxmsk] = getspmpeak(spmmat, xidx, maskfiles);
        
        % Store results
        mmpeak(optidx, :, :) = cat(1, mmhem, mmmsk);
        voxpeak(optidx, :, :) = cat(1, voxhem, voxmsk);
        
        % Get labels
        [~, llab] = getlab(mmhem);
        labpeak(optidx, :, :) = llab;
        
        % Update progress
        fprintf('\b\b\b\b\b\b%6.2f', ...
            optidx / length(optlist) * 100);
        
    end
    
    % 
    peak.(contrname).mmpeak = mmpeak;
    peak.(contrname).voxpeak = voxpeak;
    peak.(contrname).labpeak = labpeak;
    
    % 
    fprintf('\n');
    
end

% Save peak
peakfile = sprintf('%s/peak', ...
    env.statdir);
save(peakfile, 'peak');

% Write peak to text
writepeak(peak, masknames, ',', ...
    sprintf('%s/peak.txt', env.statdir));