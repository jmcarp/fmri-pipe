function so = modslov(fname, sname, mskname, slices, outname, erodim)

mskimg = spm_read_vols(spm_vol(mskname));

fvol = spm_vol(fname);
fimg = spm_read_vols(fvol);

% Erode mask
if erodim > 0
    se = strel('disk', erodim);
    mskimg = imerode(mskimg, se);
end

% Apply mask
fimg(mskimg == 0) = nan;
spm_write_vol(fvol, fimg);

% 
so = slover(spm_vol(char({fname sname})));
so.img(1).type = 'truecolor';
so.img(1).cmap = jet;
so.img(2).range = [78 7616];
so.slices = slices;
so.cbar = 1;

so = paint(so);

so.printstr = 'print -dpdf -painters -noui';
so.printfile = outname;
print_fig(so);