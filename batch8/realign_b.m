function realign_b

global CCN;
clear matlabbatch;

% Files
data = expandpath(CCN.ffiles);
data = volseq(data, false);

if isfield(CCN.realign, 'unwarp') && ...
        CCN.realign.unwarp == true
    
    eopts = struct( ...
        'quality', 0.9, ...
        'sep', 4, ...
        'fwhm', 5, ...
        'rtm', 0, ...
        'einterp', 2, ...
        'ewrap', [0 0 0], ...
        'weight', {{''}} ...
        );
    
    uweopts = spm_get_defaults('unwarp.estimate');
    if isfield(CCN.realign, 'uweopts')
        uweopts = catstruct(uweopts, CCN.realign.uweopts);
    end
    
    uwropts = spm_get_defaults('unwarp.write');
    if isfield(CCN.realign, 'uwropts')
        uwropts = catstruct(uwropts, CCN.realign.uwropts);
    end
    
    matlabbatch{1}.spm.spatial.realignunwarp.eoptions = eopts;
    matlabbatch{1}.spm.spatial.realignunwarp.uweoptions = uweopts;
    matlabbatch{1}.spm.spatial.realignunwarp.uwroptions = uwropts;
    
    % Run
    for runidx = 1 : length(data)
        matlabbatch{1}.spm.spatial.realignunwarp.data(runidx).scans = data{runidx};
        matlabbatch{1}.spm.spatial.realignunwarp.data(runidx).pmscan = '';
    end
    
else
    
    % Estimation options
    eopts = spm_get_defaults('realign.estimate');
    if isfield(CCN.realign, 'eopts')
        eopts = catstruct(eopts, CCN.realign.eopts);
    end
    
    % Write options
    wopts = spm_get_defaults('realign.write');
    if isfield(CCN.realign, 'wopts')
        wopts = catstruct(wopts, CCN.realign.wopts);
    end

    if ~CCN.realign.reslice
        matlabbatch{1}.spm.spatial.realign.estimate.data = data;
        matlabbatch{1}.spm.spatial.realign.estimate.eoptions = eopts;
    else
        matlabbatch{1}.spm.spatial.realign.estwrite.data = data;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions = eopts;
        matlabbatch{1}.spm.spatial.realign.estwrite.woptions = wopts;
    end
    
end

% Run
spm_jobman('run', matlabbatch);

% Register to structural template

if isfield(CCN.realign, 'hrreg') && ...
        CCN.realign.hrreg == true
    
    tmpdata = expandpath(CCN.ffiles);
    
    if CCN.realign.reslice
        rtmpdata = cell(size(tmpdata));
        for runidx = 1 : length(tmpdata)
            rtmpdata{runidx} = fileprep(tmpdata{runidx}, 'r');
        end
        tmpdata = [tmpdata rtmpdata];
    end
    
    meanfile = fileprep(tmpdata{1}, 'mean');
    
    oldres = CCN.coreg.reslice;
    CCN.coreg.reslice = false;
    
    coreg(CCN.norm.hrtemp, meanfile, volseq(tmpdata, true));
    
    CCN.coreg.reslice = oldres;
    
end