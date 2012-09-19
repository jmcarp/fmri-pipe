function coregister_b

global CCN;

% Load mean functional image
meanfile = expandpath(CCN.ffiles, false, 1);
meanvol = spm_vol(meanfile);

% Copy anatomical image(s)
hrfile = expandpath(CCN.hrpat, false, 1);
rmold({hrfile}, 'reg');
copyfile(hrfile, fileprep(hrfile, 'reg'));
[hrpath hrname hrext] = fileparts(hrfile);
if strcmp(hrext, '.img')
    hrhdr = sprintf('%s/%s.hdr', hrpath, hrname);
    copyfile(hrhdr, fileprep(hrhdr, 'reg'));
end

if isfield(CCN.coreg, 'hrreorient')
    matlabbatch{1}.spm.util.reorient.transform.transprm = CCN.coreg.hrreorient;
    matlabbatch{1}.spm.util.reorient.srcfiles = {fileprep(hrfile, 'reg')};
    matlabbatch{1}.spm.util.reorient.prefix = '';
    spm_jobman('run', matlabbatch);
    clear matlabbatch
end

hrvol = spm_vol(fileprep(hrfile, 'reg'));

if CCN.coreg.twostage
    ovfile = expandpath(CCN.ovpat, false, 1);
    rmold({ovfile}, 'reg');
    copyfile(ovfile, fileprep(ovfile, 'reg'));
    [ovpath ovname ovext] = fileparts(ovfile);
    if strcmp(ovext, '.img')
        ovhdr = sprintf('%s/%s.hdr', ovpath, ovname);
        copyfile(ovhdr, fileprep(ovhdr, 'reg'));
    end
    ovvol = spm_vol(fileprep(ovfile, 'reg'));
end

if CCN.coreg.twostage
    
    % Overlay to functional
    coreg(meanvol.fname, ovvol.fname);
    
    % High-res to overlay
    coreg(ovvol.fname, hrvol.fname);
    
    spm_check_registration(char({hrvol.fname, meanvol.fname}));
    spm_print;
    
else
    
%     coreg(expandpath(CCN.norm.hrtemp, false, 1), ...
%         hrvol.fname);
    
    % High-res to functional
    coreg(meanvol.fname, hrvol.fname);
    
end