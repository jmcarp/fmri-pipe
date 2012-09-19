function modclean_b

global CCN;

spmdir = expandpath(CCN.model.model_dir, false, 1);
spmmat = sprintf('%s/SPM.mat', spmdir);

load(spmmat);

for contridx = 1 : length(SPM.xCon)
    if regexp(SPM.xCon(contridx).name, 'basis\d+')
        statfile = sprintf('%s/%s', ...
            spmdir, SPM.xCon(contridx).Vspm.fname);
        hdrfile = chext(statfile, '.hdr');
        delete(statfile);
        delete(hdrfile);
    end
end

% Clean misc
cmd = sprintf('rm %s/RPV*', spmdir);
system(cmd);
cmd = sprintf('rm %s/ess*', spmdir);
system(cmd);
cmd = sprintf('rm %s/Res*', spmdir);
system(cmd);
cmd = sprintf('rm %s/mask*', spmdir);
system(cmd);

% Clean SPM.mat
if isfield(CCN.modclean, 'cleanspm') && ...
        CCN.modclean.cleanspm == true
    cmd = sprintf('rm %s/SPM.mat', spmdir);
    system(cmd);
end

% Clean beta*
if isfield(CCN.modclean, 'cleanbeta') && ...
        CCN.modclean.cleanbeta == true
    cmd = sprintf('rm %s/beta*', spmdir);
    system(cmd);
end

% Clean spmT*
if isfield(CCN.modclean, 'cleanspmt') && ...
        CCN.modclean.cleanspmt == true
    cmd = sprintf('rm %s/spmT*', spmdir);
    system(cmd);
end

% Clean spmF_0001*
if isfield(CCN.modclean, 'cleanspmf1') && ...
        CCN.modclean.cleanspmf1 == true
    cmd = sprintf('rm %s/spmF_0001*', spmdir);
    system(cmd);
end

% Clean spmF*
if isfield(CCN.modclean, 'cleanspmt') && ...
        CCN.modclean.cleanspmf == true
    cmd = sprintf('rm %s/spmF*', spmdir);
    system(cmd);
end

% Pack
if isfield(CCN.modclean, 'pack') && ...
        CCN.modclean.pack == true
    [pathstr name] = fileparts(spmdir);
    startdir = pwd;
    cd(pathstr);
    gzname = sprintf('%s.tar.gz', name);
    if exist(gzname, 'file')
        delete(gzname);
    end
    cmd = sprintf('tar zcvf %s.tar.gz %s', ...
        name, name);
    system(cmd);
    rmdir(spmdir, 's');
    cd(startdir);
end