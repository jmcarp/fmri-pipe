function despike_b

global CCN;

% Load data
data = expandpath(CCN.ffiles);

% Remove old files
rmold(data, 'd');

% Skip if requested
if isfield(CCN.despike, 'skip') && ...
        CCN.despike.skip == true
    for runidx = 1 : length(data)
        oldname = data{runidx};
        newname = fileprep(oldname, 'd');
        niicopy(oldname, newname);
%         copyfile(oldname, newname);
    end
    return
end

% Get options
if isfield(CCN.despike, 'opts')
    opts = CCN.despike.opts;
else
    opts = '';
end

% Open log
logname = sprintf('%s/%s_despike.txt', CCN.logdir, CCN.csubject);
if ~exist(CCN.logdir, 'dir')
    mkdir(CCN.logdir);
end
logfile = fopen(logname, 'w');

for runidx = 1 : length(data)
    
    % Get path
    runname = data{runidx};
    [path name] = fileparts(runname);
    
    % Update log
    fprintf(logfile, 'Working on run %d...\n', runidx);
    
    % Remove existing despiked data
    dsbrik = sprintf('%s/despike+orig.BRIK', path);
    dshead = sprintf('%s/despike+orig.HEAD', path);
    dsnii = fileprep(runname, 'd');
    if exist(dsbrik, 'file')
        delete(dsbrik);
    end
    if exist(dshead, 'file')
        delete(dshead);
    end
    if exist(dsnii, 'file')
        cmd = sprintf('rm %s/d%s*', path, name);
        system(cmd);
    end
    
    % Run 3dDespike
    cmd = sprintf('3dDespike -prefix %s/despike %s %s', path, opts, runname);
    [~, result] = system(cmd);
    fprintf(logfile, '%s', result);
    
    % Convert to NIFTI
    cmd = sprintf('3dAFNItoNIFTI -prefix %s/d%s %s/despike+orig', path, name, path);
    system(cmd);
    
    if isfield(CCN.despike, 'gethdr') && CCN.despike.gethdr
        
        vol = spm_vol(runname);
        dvol = spm_vol(dsnii);
        dimg = spm_read_vols(dvol);
        
        [dspath dsname] = fileparts(dsnii);
        delete(sprintf('%s/%s*', dspath, dsname));
%         delete(dsnii);
        
        newhdr = vol;
        for volidx = 1 : length(newhdr)
            newhdr(volidx).fname = dvol(volidx).fname;
            spm_write_vol(newhdr(volidx), dimg(:, :, :, volidx));
        end
        
    end
    
end

% Close log
fclose(logfile);
