function model_b

global CCN;
clear matlabbatch;

data = expandpath(CCN.ffiles);

rpfiles = expandpath(CCN.rppat);
rpnames = { 'xtrans' 'ytrans' 'ztrans' 'pitch' 'roll' 'yaw' };

% Set directory
adir = expandpath(CCN.model.model_dir, false, 1);
if ~exist(adir, 'dir')
    mkdir(adir);
elseif exist(sprintf('%s/SPM.mat', adir), 'file')
    if isfield(CCN.model, 'overwrite') && CCN.model.overwrite
        cmd = sprintf('rm %s/*', adir);
        system(cmd);
    else
        warning('skipping model specification / estimation for subject %s', CCN.subject);
        return;
    end
end
job.dir = {adir};

catrpdat = [];
for runidx = 1 : length(rpfiles)
    catrpdat = [catrpdat ; load(rpfiles{runidx})];
end
catrpfile = sprintf('%s/mot.txt', adir);
dlmwrite(catrpfile, catrpdat, 'delimiter', '\t');

% Load defaults
if isfield(CCN.model, 'cvi')
    job.cvi = CCN.model.cvi;
else
    job.cvi = spm_get_defaults('stats.fmri.cvi');
end

if isfield(CCN.model, 'global')
    job.global = CCN.model.global;
end

if isfield(CCN.model, 'mask')
    job.mask = {expandpath(CCN.model.mask, false, 1)};
end

job.timing.fmri_t = ...
    spm_get_defaults('stats.fmri.fmri_t');
job.timing.fmri_t0 = ...
    spm_get_defaults('stats.fmri.fmri_t0');

% Set up basis functions
if isfield(CCN.model, 'basis')
    if strcmp(CCN.model.basis, 'hrf')
        if isfield(CCN.model, 'derivs')
            switch CCN.model.derivs
                case 'none'
                    job.bases.hrf.derivs = [ 0 0 ];
                case 'time'
                    job.bases.hrf.derivs = [ 1 0 ];
                case 'disp'
                    job.bases.hrf.derivs = [ 1 1 ];
            end
        else
            job.bases.hrf.derivs = [ 0 0 ];
        end
    elseif strcmp(CCN.model.basis, 'fir')
        job.bases.fir.length = ...
            CCN.model.length;
        job.bases.fir.order = ...
            CCN.model.length / CCN.TR;
    else
        error('basis %s not implemented', CCN.model.basis);
    end
end

% Load required parameters
job.timing.units = CCN.model.units;
job.timing.RT = CCN.TR;

% Load spec file
specfile = expandpath(CCN.model.spec_file, false, 1);
[~, ~, ext] = fileparts(specfile);
if strcmp(ext, '.mat')
    load(specfile);
elseif strcmp(ext, '.m')
    spec = [];
    run(specfile);
end

% Load conditions

if ~isfield(CCN.model, 'catruns') || ~CCN.model.catruns

    for runidx = 1 : length(data)
    % for runidx = 1 : length(spec)

        if ~isfield(CCN.model, 'hpf')
            job.sess(runidx).hpf = ...
                spm_get_defaults('stats.fmri.hpf');
        else
            job.sess(runidx).hpf = ...
                CCN.model.hpf;
        end
        
        % Load onsets
        for condidx = 1 : length(spec{runidx})
            job.sess(runidx).cond(condidx).name = ...
                spec{runidx}{condidx}.name;
            job.sess(runidx).cond(condidx).onset = ...
                spec{runidx}{condidx}.onset;
            job.sess(runidx).cond(condidx).tmod = 0;
            
            if isfield(spec{runidx}{condidx}, 'param')
                for paridx = 1 : length(spec{runidx}{condidx}.param)
                    job.sess(runidx).cond(condidx).pmod(paridx) = ...
                        spec{runidx}{condidx}.param(paridx);
                end
            end
            
            if isfield(spec{runidx}{condidx}, 'dur')
                job.sess(runidx).cond(condidx).duration = ...
                    spec{runidx}{condidx}.dur;
            else
                job.sess(runidx).cond(condidx).duration = 0;
            end

        end

        % Load data
        voltmp = volseq(data{runidx}, true);
        if isfield(CCN.model, 'droplast')
            voltmp = voltmp(1 : end - CCN.model.droplast);
        end
        job.sess(runidx).scans = voltmp;

        % Get motion regressors
        if CCN.model.rpreg
            regs = getmotreg(rpfiles(runidx));
            job.sess(runidx).regress = regs;
        end
        job.sess(runidx).multi = {''};

    end

else
    
    if ~isfield(CCN.model, 'hpf')
        job.sess(1).hpf = ...
            spm_get_defaults('stats.fmri.hpf');
    else
        job.sess(1).hpf = ...
            CCN.model.hpf;
    end
    
    tmpscans = volseq(data, false);
    
    % Load onsets
    for condidx = 1 : length(spec{1})
        
%         matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx).name = ...
%             spec{1}{condidx}.name;
%         matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx).onset = ...
%             [];
%         matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx).duration = ...
%             [];
        job.sess(1).cond(condidx).name = spec{1}{condidx}.name;
        job.sess(1).cond(condidx).onset = [];
        job.sess(1).cond(condidx).duration = [];
        job.sess(1).cond(condidx).tmod = 0;
            
        offset = 0;
        
        for runidx = 1 : length(spec)
        
%             matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx).onset = ...
%                 [ matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx).onset ...
%                 spec{runidx}{condidx}.onset + offset ];
            job.sess(1).cond(condidx).onset = ...
                [ job.sess(1).cond(condidx).onset ...
                spec{runidx}{condidx}.onset' + offset ];
            if strcmp(CCN.model.units, 'scans')
                offset = offset + length(tmpscans{runidx});
            elseif strcmp(CCN.model.units, 'secs')
                offset = offset + CCN.TR * length(tmpscans{runidx});
            end

            if isfield(spec{1}{condidx}, 'param')
%                 if ~isfield(matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx), 'pmod')
%                     matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond.pmod = [];
%                 end
                if ~isfield(job.sess(1).cond(condidx), 'pmod')
                    job.sess(1).cond(condidx).pmod = ...
                        spec{1}{condidx}.param;
                end
                for paridx = 1 : length(spec{1}{condidx}.param)
%                     if length(matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx).pmod) < paridx
%                         matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx).pmod(paridx) = 0;
%                     end
%                     matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx).pmod(paridx) = ...
%                         [ matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx).pmod(paridx) ...
%                         spec{runidx}{condidx}.param(paridx) ];
%                     if length(job.sess(1).cond(condidx).pmod) < paridx
%                         job.sess(1).cond(condidx).pmod(paridx) = 0;
%                     end
                    if runidx > 1
                        job.sess(1).cond(condidx).pmod(paridx).param = ...
                            [ job.sess(1).cond(condidx).pmod(paridx).param ; ...
                            spec{runidx}{condidx}.param(paridx).param ];
                    end
                end
            end

%             if isfield(spec{1}{condidx}, 'dur')
%                 matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx).duration = ...
%                     [ matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx).duration ...
%                     spec{runidx}{condidx}.dur ];
%             else
%                 matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx).duration = ...
%                     0;
%             end
            if isfield(spec{1}{condidx}, 'dur')
                job.sess(1).cond(condidx).duration = ...
                    [ job.sess(1).cond(condidx).duration ...
                    spec{runidx}{condidx}.dur' ];
            else
                job.sess(1).cond(condidx).duration = ...
                    0;
            end
        
        end
        
    end
    
    % Load data
    scans = volseq(data, true);
%     matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = scans;
    job.sess(1).scans = scans;
    
    % Get constant regressors
    nvols = nan(length(tmpscans), 1);
    for runidx = 1 : length(tmpscans)
        nvols(runidx) = length(tmpscans{runidx});
    end
    cregs = getconstreg(length(data), nvols);
    
    if CCN.model.rpreg
    
        % Get motion regressors
        mpregs = getmotreg(rpfiles);
        
    else
        
        mpregs = [];
        
    end
    
    job.sess(1).regress = [mpregs cregs];
    
end

if ~isfield(CCN.model, 'wls') | ~CCN.model.wls
    matlabbatch{1}.spm.stats.fmri_spec = job;
else
    job.volt = 1;
    if ~isfield(job, 'volt')
        job.global = 'None';
    end
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec = job;
end

spmmat = sprintf('%s/SPM.mat', adir);

% Estimation
if ~isfield(CCN.model, 'wls') | ~CCN.model.wls
    matlabbatch{2}.spm.stats.fmri_est.spmmat = ...
        {spmmat};
else
    matlabbatch{2}.spm.tools.rwls.fmri_rwls_est.spmmat = ...
        {spmmat};
    matlabbatch{3}.spm.tools.rwls.fmri_rwls_plotres.spmmat_plot = {spmmat};
    matlabbatch{3}.spm.tools.rwls.fmri_rwls_plotres.movparam = {catrpfile};
end

% Run job
spm_jobman('run', matlabbatch(1));
spm_print;

if isfield(CCN.model, 'thresh')
    load(spmmat);
    SPM.xM.T = SPM.xM.T .* CCN.model.thresh;
    SPM.xM.TH = SPM.xM.TH .* CCN.model.thresh;
    save(spmmat, 'SPM');
end

% Run job
if isfield(CCN.model, 'est') && ...
        CCN.model.est == true
    spm_jobman('run', matlabbatch(2 : end));
    if isfield(CCN.model, 'wls') && ...
            CCN.model.wls == true
        spm_print;
    end
end

function regs = getmotreg(rpfiles)
    
    rpdata = [];
    names = {};
    nameidx = 1;
    for rpidx = 1 : length(rpfiles)
        
        rptmp = load(rpfiles{rpidx});
        rptmp = mcenter(rptmp);
        rpexp = [];
        
        regidx = 1;
        for pow = 1 : CCN.model.rppow
            for spin = 0 : CCN.model.rpspin
                for rpidx = 1 : size(rptmp, 2)
                    rpname = rpnames{mod(rpidx - 1, 6) + 1};
                    names{nameidx} = sprintf('%s b%d ^%d +t%d', ...
                        rpname, floor((rpidx - 1) / 6) + 1, pow, spin);
                    rpexp(:, regidx) = [zeros(spin, 1) ; rptmp(1 : end - spin, rpidx)] .^ pow;
                    regidx = regidx + 1;
                    nameidx = nameidx + 1;
                end
            end
        end
        
        rpdata = blkdiag(rpdata, mcenter(rpexp));
        
    end
    
    if isfield(CCN.model, 'droplast')
        droplast = CCN.model.droplast;
    else
        droplast = 0;
    end
    
    for regidx = 1 : size(rpdata, 2)
        regs(regidx).name = names{regidx};
        regs(regidx).val = rpdata(1 : end - droplast, regidx);
    end
    
end

function regs = getconstreg(nruns, nvols)
    
    if nruns == 1
        regs = [];
        return
    end
    
    const = [];
    
    for runidx = 1 : nruns
        const = blkdiag(const, ones(nvols(runidx), 1));
    end
    
    for regidx = 1 : (nruns - 1)
        regs(regidx).name = sprintf('const s%d', regidx);
        regs(regidx).val = const(:, regidx);
    end
    
end

end
