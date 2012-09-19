function reorient_b

global CCN;
clear matlabbatch;

% Reorient functional files
fdata = expandpath(CCN.ffiles);

fjob = struct();
fjob.srcfiles = volseq(fdata, true);
fjob.prefix = '';
% fjob.prefix = 'o';
fjob.transform.transprm = CCN.reorient.func;

% Reorient structural files
sdata = expandpath(CCN.afiles);

sjob = struct();
sjob.srcfiles = volseq(sdata, true);
sjob.prefix = '';
% sjob.prefix = 'o';
sjob.transform.transprm = CCN.reorient.struct;

% Set up matlabbatch
matlabbatch{1}.spm.util.reorient = fjob;
matlabbatch{2}.spm.util.reorient = sjob;

% Run matlabbatch
spm_jobman('run', matlabbatch);
