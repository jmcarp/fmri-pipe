function bet_b

global CCN;
clear matlabbatch;

% Get file names
hrfile = expandpath(CCN.hrpat, false, 1);
infile = fileprep(hrfile, 'reg');
outfile = fileprep(hrfile, 'breg');
gzfile = sprintf('%s.gz', outfile);

% Get options
if isfield(CCN.bet, 'opts')
    opts = CCN.bet.opts;
else
    opts = '';
end

% Delete existing bet files
if exist(outfile, 'file')
    delete(outfile);
end
if exist(gzfile, 'file')
    delete(gzfile);
end

% Run BET
cmd = sprintf('bet %s %s %s', infile, outfile, opts);
system(cmd);

% Unzip results
cmd = sprintf('gunzip -f %s.gz', outfile);
system(cmd);

% Print results
matlabbatch{1}.spm.util.checkreg.data = {infile outfile};
matlabbatch{2}.spm.util.print.fname = sprintf('%s/%s_%s.ps', ...
    CCN.psdir, CCN.subject, CCN.step);

spm_jobman('run', matlabbatch);