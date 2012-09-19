function coreg(tofile, fromfile, varargin)

if nargin >= 3
    othfile = varargin{1};
end

global CCN;

% Estimation options
eopts = spm_get_defaults('coreg.estimate');
if isfield(CCN.coreg, 'eopts')
    eopts = catstruct(eopts, CCN.coreg.eopts);
end

% Write options
wopts = spm_get_defaults('coreg.write');
if isfield(CCN.coreg, 'wopts')
    wopts = catstruct(wopts, CCN.coreg.wopts);
end

if ~CCN.coreg.reslice
    matlabbatch{1}.spm.spatial.coreg.estimate.ref = {tofile};
    matlabbatch{1}.spm.spatial.coreg.estimate.source = {fromfile};
    if exist('othfile', 'var')
        matlabbatch{1}.spm.spatial.coreg.estimate.other = othfile;
    end
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions = eopts;
else
    matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {tofile};
    matlabbatch{1}.spm.spatial.coreg.estwrite.source = {fromfile};
    if exist('othfile', 'var')
        matlabbatch{1}.spm.spatial.coreg.estimate.other = {othfile};
    end
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions = eopts;
    matlabbatch{1}.spm.spatial.coreg.estwrite.woptions = wopts;
end

% Run
spm_jobman('run', matlabbatch);