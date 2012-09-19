function smooth_b

global CCN;
clear matlabbatch;

% Options
opts = spm_get_defaults('smooth');
if isfield(CCN.smooth, 'opts')
    opts = catstruct(opts, CCN.smooth.opts);
end

% Get files
data = expandpath(CCN.ffiles);

% Remove old files
rmold(data, 's');

matlabbatch{1}.spm.spatial.smooth = opts;

matlabbatch{1}.spm.spatial.smooth.data = volseq(data, true);

spm_jobman('run', matlabbatch);