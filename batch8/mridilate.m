function outname = mridilate(imgname, radius, thresh, operator)

vol = spm_vol(imgname);
img = spm_read_vols(vol);
outvol = vol;
outimg = img > thresh;

voxdim =  sqrt(sum(vol.mat(1 : 3, 1 : 3) .^ 2));
[sphvox nhood] = getsphere(radius, voxdim);
el = strel('arbitrary', nhood);

if strcmp(operator, 'dil')
    outimg = imdilate(outimg, el);
    outname = fileprep(vol.fname, 'dil');
elseif strcmp(operator, 'erode')
    outimg = imerode(outimg, el);
    outname = fileprep(vol.fname, 'ero');
end

outvol.fname = outname;
spm_write_vol(outvol, outimg);