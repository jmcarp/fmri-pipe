function segment_b

global CCN;
clear matlabbatch;

hrfile = expandpath(CCN.hrpat, false, 1);
hrfile = fileprep(hrfile, 'reg');

if strcmp(CCN.seg.method, 'spm')
    
    matlabbatch{1}.spm.spatial.preproc.data = {hrfile};
    matlabbatch{1}.spm.spatial.preproc.output.GM = [0 1 1];
    matlabbatch{1}.spm.spatial.preproc.output.WM = [0 1 1];
    matlabbatch{1}.spm.spatial.preproc.output.CSF = [0 1 1];
    
    cpref = 'c';
    
elseif strcmp(CCN.seg.method, 'vbm')
    
    matlabbatch{1}.spm.tools.vbm8.estwrite.data = {hrfile};
    matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.dartelwarp.normlow = ...
        struct('null', {});
    matlabbatch{1}.spm.tools.vbm8.estwrite.output.GM.native = 1;
    matlabbatch{1}.spm.tools.vbm8.estwrite.output.GM.warped = 1;
    matlabbatch{1}.spm.tools.vbm8.estwrite.output.WM.native = 1;
    matlabbatch{1}.spm.tools.vbm8.estwrite.output.WM.warped = 1;
    matlabbatch{1}.spm.tools.vbm8.estwrite.output.CSF.native = 1;
    matlabbatch{1}.spm.tools.vbm8.estwrite.output.warps = [ 1 1 ];
    
    cpref = 'p';
    
end

% Print results
c1file = chext(fileprep(hrfile, sprintf('%s1', cpref)), '.nii');
c2file = chext(fileprep(hrfile, sprintf('%s2', cpref)), '.nii');
c3file = chext(fileprep(hrfile, sprintf('%s3', cpref)), '.nii');

spm_jobman('run', matlabbatch);

% Write brain mask
c1vol = spm_vol(c1file);
c1img = spm_read_vols(c1vol);
c2vol = spm_vol(c2file);
c2img = spm_read_vols(c2vol);
c3vol = spm_vol(c3file);
c3img = spm_read_vols(c3vol);

csum = c1img + c2img + c3img;
cmsk = csum > .75;

c1vol.fname = fileprep(hrfile, 'msk');
spm_write_vol(c1vol, cmsk);
%spm_smooth(c1vol.fname, c1vol.fname, [1 1 1]);

% Write scalped image
mskvol = spm_vol(c1vol.fname);
mskimg = spm_read_vols(mskvol);

hrvol = spm_vol(hrfile);
hrimg = spm_read_vols(hrvol);
hrimg(mskimg == 0) = 0;

hrvol.fname = fileprep(hrfile, 's');
spm_write_vol(hrvol, hrimg);

if strcmp(CCN.seg.method, 'spm')
    clear matlabbatch;
    matlabbatch{1}.spm.util.checkreg.data = { ...
        c1file ...
        c2file ...
        c3file ...
        hrvol.fname ...
        };
    spm_jobman('run', matlabbatch);
    spm_print;
end
