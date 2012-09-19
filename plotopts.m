function plotopts

global CCN;
if isempty(CCN)
    batchpar_008;
end

sname = '/data00/jmcarp/tools/templates/MNI152_T1_1mm.nii';
slices = -25 : 15 : 75;
erodim = 5;

doreslice = true;

imtype = 'spmF';
contrname = 'sstopvsgo';

opts = { ...
    'none_slice_realign_def_def_anat_fwhm4_none_none_none_hrf_none' ...
%     'none_slice_realign_def_def_anat_fwhm4_none_none_none_fir_rp6' ...
    'none_slice_realign_def_def_anat_fwhm8_hpf128_none_none_fir_rp6' ...
};

savdir = sprintf('%s/figs.opt', CCN.root_dir);

for optidx = 1 : length(opts)

    optname = opts{optidx};
    
    % Get SPM.mat
    spmdir = sprintf('%s/permrfx/%s/%s', ...
        CCN.root_dir, optname, contrname);
    spmmat = sprintf('%s/SPM.mat', spmdir);

    % Load SPM.mat
    load(spmmat);
    xnames = {SPM.xCon.name};
    xidx = find(ismember(xnames, 'Effects of Interest'), 1);

    % Get spm* file
    fname = sprintf('%s/%s_%04d.img', ...
        spmdir, imtype, xidx);

    % Get degrees of freedom
    df1 = round(SPM.xCon(xidx).eidf);
    df2 = round(SPM.xX.erdf);
    
    vol = spm_vol(fname);
    img = spm_read_vols(vol);
    
    zvol = vol;
    zvol.fname = fileprep(vol.fname, 'z');
    zimg = f2z(img, df1, df2, 1);
    spm_write_vol(zvol, zimg);

    outname = sprintf('%s/%s', ...
        savdir, optname);
    
    figure
    [~, doreslice] = permso(zvol.fname, CCN.model.mask, sname, ...
        slices, erodim, outname, [0 6.5]);

end