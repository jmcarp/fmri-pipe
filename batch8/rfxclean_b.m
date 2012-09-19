function rfxclean_b

global CCN;

rfxdir = expandpath(CCN.rfx.dir, false, 1);

contrnames = fieldnames(CCN.contr.contrs);

for contridx = 1 : length(contrnames)

    contrname = contrnames{contridx};
    
    spmdir = sprintf('%s/%s', rfxdir, contrname);

    % Clean SPM.mat
    if isfield(CCN.rfxclean, 'cleanspm') && ...
            CCN.rfxclean.cleanspm == true
        cmd = sprintf('rm %s/SPM.mat', spmdir);
        system(cmd);
    end
    
    % Clean beta*
    if isfield(CCN.rfxclean, 'cleanbeta') && ...
            CCN.rfxclean.cleanbeta == true
        cmd = sprintf('rm %s/beta*', spmdir);
        system(cmd);
    end

    % Clean spmT*
    if isfield(CCN.rfxclean, 'cleanspmt') && ...
            CCN.rfxclean.cleanspmt == true
        cmd = sprintf('rm %s/spmT*', spmdir);
        system(cmd);
    end

    % Clean spmF_0001*
    if isfield(CCN.rfxclean, 'cleanspmf1') && ...
            CCN.rfxclean.cleanspmf1 == true
        cmd = sprintf('rm %s/spmF_0001*', spmdir);
        system(cmd);
    end

    % Clean spmF*
    if isfield(CCN.rfxclean, 'cleanspmf') && ...
            CCN.rfxclean.cleanspmf == true
        cmd = sprintf('rm %s/spmF*', spmdir);
        system(cmd);
    end

    % Pack
    if isfield(CCN.rfxclean, 'pack') && ...
            CCN.rfxclean.pack == true
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
    
end