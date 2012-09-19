function niicopy(inname, outname)

vol = spm_vol(inname);
img = spm_read_vols(vol);

if exist(outname)
    delete(outname);
end

outmat = chext(outname, '.mat');
if exist(outmat)
    delete(outmat);
end

newvol = vol;
for volidx = 1 : length(newvol)
    newvol(volidx).fname = outname;
    spm_write_vol(newvol(volidx), img(:, :, :, volidx));
end