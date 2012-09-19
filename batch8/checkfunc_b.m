function checkfunc_b

global CCN;
clear matlabbatch;

data = expandpath(CCN.ffiles);
data = volseq(data, false);

for runidx = 1 : length(data)
    data{runidx} = data{runidx}{1};
end

matlabbatch{1}.spm.util.checkreg.data = data;

spm_jobman('run', matlabbatch);

spm_print;