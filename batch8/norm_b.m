function norm_b

global CCN;
clear matlabbatch;

if isfield(CCN, 'hrpat')
    hrfile = expandpath(CCN.hrpat, false, 1);
    if ~isfield(CCN.norm, 'prefix')
        prefix = 'reg';
    else
        prefix = sprintf('%sreg', CCN.norm.prefix);
    end
    hrvol = spm_vol(fileprep(hrfile, prefix));
    [path name] = fileparts(hrfile);
end

% Estimation options
eopts = spm_get_defaults('normalise.estimate');
if isfield(CCN.norm, 'eopts')
    eopts = catstruct(eopts, CCN.norm.eopts);
end

% Write options
swopts = spm_get_defaults('normalise.write');
if isfield(CCN.norm, 'swopts')
    swopts = catstruct(swopts, CCN.norm.swopts);
end

fwopts = spm_get_defaults('normalise.write');
if isfield(CCN.norm, 'fwopts')
    fwopts = catstruct(fwopts, CCN.norm.fwopts);
end

if strcmp(CCN.norm.normtype, 'func')
    
    eopts.template = {fullfile(spm('Dir'), 'templates', 'EPI.nii')};
    
    srcfile = expandpath(CCN.meanpat, false, 1);
    [srcpath srcname] = fileparts(srcfile);
    
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.source = ...
        {srcfile};
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = ...
        {srcfile};
    matname = sprintf('%s/%s_sn.mat', srcpath, srcname);
    
elseif strcmp(CCN.norm.normtype, 'anat')
    
    eopts.template = {CCN.norm.hrtemp};
    
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.source = ...
        {hrvol.fname};
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = ...
        {hrvol.fname};
    matname = sprintf('%s/%s%s_sn.mat', path, prefix, name);
    
elseif strcmp(CCN.norm.normtype, 'seg')
    
%     error('not implemented');
    matname = sprintf('%s/reg%s_seg_sn.mat', path, name);
    
end

batchidx = 1;

if ismember(CCN.norm.normtype, {'func' 'anat'})
    
    matlabbatch{batchidx}.spm.spatial.normalise.estwrite.eoptions = eopts;
    matlabbatch{batchidx}.spm.spatial.normalise.estwrite.roptions = swopts;
    batchidx = batchidx + 1;
    
end

if CCN.norm.writenorm
    
    data = expandpath(CCN.ffiles);
    
    % Remove old files
    rmold(data, 'w');
    
    if isfield(CCN, 'normmodorder') && ...
            strcmp(CCN.normmodorder.first, 'modfirst')
        
        for runidx = 1 : length(data)
            oldname = fileprep(data{runidx}, 'r');
            newname = fileprep(data{runidx}, 'w');
            niicopy(oldname, newname);
        end
        
    else
        
        matlabbatch{batchidx}.spm.spatial.normalise.write.subj.resample = ...
            volseq(data, true);
        matlabbatch{batchidx}.spm.spatial.normalise.write.subj.matname = ...
            {matname};
        matlabbatch{batchidx}.spm.spatial.normalise.write.roptions = fwopts;
        
    end
    
end

if exist('matlabbatch', 'var')
    spm_jobman('run', matlabbatch);
end

spm_print;