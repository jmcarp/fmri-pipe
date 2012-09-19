function normalise_b

global CCN;
clear matlabbatch;

if isfield(CCN, 'hrpat')
    hrfile = expandpath(CCN.hrpat, false, 1);
%     if ~isfield(CCN.norm, 'bet') || ~CCN.norm.bet
%         prefix = 'reg';
%     else
%         prefix = 'breg';
%     end
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
    
    error('not implemented');
    matname = sprintf('%s/reg%s_seg_sn.mat', path, name);
    
end

matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions = eopts;
matlabbatch{1}.spm.spatial.normalise.estwrite.roptions = swopts;

if CCN.norm.writenorm
    
    % Get files
    data = expandpath(CCN.ffiles);
    
    % Remove old files
    rmold(data, 'w');
    
    matlabbatch{2}.spm.spatial.normalise.write.subj.resample = ...
        volseq(data, true);
    matlabbatch{2}.spm.spatial.normalise.write.subj.matname = ...
        {matname};
    matlabbatch{2}.spm.spatial.normalise.write.roptions = fwopts;
    
end

spm_jobman('run', matlabbatch);

spm_print;