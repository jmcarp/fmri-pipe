function coreg_fsl(tovol, fromvol)

global CCN;

fprintf('registering...\n%s to \n%s...', ...
    fromvol.fname, tovol.fname);

[frompath fromname fromext] = fileparts(fromvol.fname);

% Delete parameter file if exists
matname = sprintf('%s/coreg.mat', frompath);
if exist(matname, 'file')
    delete(matname);
end

% Delete ...
outname = fileprep(fromvol.fname, 'r');
if exist(outname, 'file')
    delete(outname);
end

estcmd = sprintf('flirt -in %s -ref %s -omat %s -dof 6', ...
    fromvol.fname, tovol.fname, matname);
system(estcmd);

rescmd = sprintf('flirt -in %s -ref %s -out %s -init %s -applyisoxfm 1', ...
    fromvol.fname, tovol.fname, outname, matname);
system(rescmd);

guncmd = sprintf('gunzip -f %s.gz', outname);
system(guncmd);