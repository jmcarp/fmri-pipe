function make_permjobs

global CCN;
if isempty(CCN)
    batchpar_008;
end

p = getpermlist;
env = getpenv(p, CCN);

subjs = CCN.subjs;

for subjidx = 1 : length(subjs)
    
    subj = CCN.subjs{subjidx};
    
    jobname = sprintf('%s/job_%s.m', ...
        env.jobdir, subj);
    fh = fopen(jobname, 'w');
    
    fprintf(fh, 'batchpar_008;\n');
    fprintf(fh, 'global CCN;\n');
    
    fprintf(fh, 'CCN.subjs = { ''%s'' };\n', ...%CCN.subjs(%d);\n', ...
        subj);%subjidx);
    fprintf(fh, 'CCN.subject = ''%s'';\n', subj);
    
    fprintf(fh, 'mripermute;\n');
    
    fclose(fh);
    
end