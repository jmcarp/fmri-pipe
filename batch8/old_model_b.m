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
matlabbatch{1}.spm.stats.fmri_spec.dir = {adir};

% Load defaults
% if isfield(CCN.model, 'catruns') && CCN.model.catruns
%     matlabbatch{1}.spm.stats.fmri_spec.cvi = 'none';
% else
if isfield(CCN.model, 'cvi')
    matlabbatch{1}.spm.stats.fmri_spec.cvi = ...
        CCN.model.cvi;
else
    matlabbatch{1}.spm.stats.fmri_spec.cvi = ...
        spm_get_defaults('stats.fmri.cvi');
end

if isfield(CCN.model, 'global')
    matlabbatch{1}.spm.stats.fmri_spec.global = ...
        CCN.model.global;
end

if isfield(CCN.model, 'mask')
    matlabbatch{1}.spm.stats.fmri_spec.mask = ...
        {expandpath(CCN.model.mask, false, 1)};
end

matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = ...
    spm_get_defaults('stats.fmri.fmri_t');
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = ...
    spm_get_defaults('stats.fmri.fmri_t0');

% Set up basis functions
if isfield(CCN.model, 'basis')
    if strcmp(CCN.model.basis, 'hrf')
        if isfield(CCN.model, 'derivs')
            switch CCN.model.derivs
                case 'none'
                    matlabbatch{1}.spm.stats.fmri_spec.basis.hrf.derivs = [ 0 0 ];
                case 'time'
                    matlabbatch{1}.spm.stats.fmri_spec.basis.hrf.derivs = [ 1 0 ];
                case 'disp'
                    matlabbatch{1}.spm.stats.fmri_spec.basis.hrf.derivs = [ 1 1 ];
            end
        end
    elseif strcmp(CCN.model.basis, 'fir')
        matlabbatch{1}.spm.stats.fmri_spec.bases.fir.length = ...
            CCN.model.length;
        matlabbatch{1}.spm.stats.fmri_spec.bases.fir.order = ...
            CCN.model.length / CCN.TR;
    else
        error('basis %s not implemented', CCN.model.basis);
    end
end

% Load required parameters
matlabbatch{1}.spm.stats.fmri_spec.timing.units = CCN.model.units;
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = CCN.TR;

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

    for runidx = 1 : length(spec)

        if ~isfield(CCN.model, 'hpf')
            matlabbatch{1}.spm.stats.fmri_spec.sess(runidx).hpf = ...
                spm_get_defaults('stats.fmri.hpf');
        else
            matlabbatch{1}.spm.stats.fmri_spec.sess(runidx).hpf = ...
                CCN.model.hpf;
        end

        % Load onsets
        for condidx = 1 : length(spec{runidx})
            matlabbatch{1}.spm.stats.fmri_spec.sess(runidx).cond(condidx).name = ...
                spec{runidx}{condidx}.name;
            matlabbatch{1}.spm.stats.fmri_spec.sess(runidx).cond(condidx).onset = ...
                spec{runidx}{condidx}.onset;

            if isfield(spec{runidx}{condidx}, 'param')
                for paridx = 1 : length(spec{runidx}{condidx}.param)
                    matlabbatch{1}.spm.stats.fmri_spec.sess(runidx).cond(condidx).pmod(paridx) = ...
                        spec{runidx}{condidx}.param(paridx);
                end
            end

            if isfield(spec{runidx}{condidx}, 'dur')
                matlabbatch{1}.spm.stats.fmri_spec.sess(runidx).cond(condidx).duration = ...
                    spec{runidx}{condidx}.dur;
            else
                matlabbatch{1}.spm.stats.fmri_spec.sess(runidx).cond(condidx).duration = 0;
            end

        end

        % Load data
        matlabbatch{1}.spm.stats.fmri_spec.sess(runidx).scans = ...
            volseq(data{runidx}, true);

        % Get motion regressors
        if CCN.model.rpreg
            regs = getmotreg(rpfiles(runidx));
            matlabbatch{1}.spm.stats.fmri_spec.sess(runidx).regress = regs;
        end

    end

else
    
    if ~isfield(CCN.model, 'hpf')
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf = ...
            spm_get_defaults('stats.fmri.hpf');
    else
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf = ...
            CCN.model.hpf;
    end
    
    tmpscans = volseq(data, false);
    
    % Load onsets
    for condidx = 1 : length(spec{1})
        
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx).name = ...
            spec{1}{condidx}.name;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx).onset = ...
            [];
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx).duration = ...
            [];
        
        offset = 0;
        
        for runidx = 1 : length(spec)
        
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx).onset = ...
                [ matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx).onset ...
                spec{runidx}{condidx}.onset + offset ];
            if strcmp(CCN.model.units, 'scans')
                offset = offset + length(tmpscans{runidx});
            elseif strcmp(CCN.model.units, 'secs')
                offset = offset + CCN.TR * length(tmpscans{runidx});
            end

            if isfield(spec{1}{condidx}, 'param')
                if ~isfield(matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx), 'pmod')
                    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond.pmod = [];
                end
                for paridx = 1 : length(spec{1}{condidx}.param)
                    if length(matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx).pmod) < paridx
                        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx).pmod(paridx) = 0;
                    end
                    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx).pmod(paridx) = ...
                        [ matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx).pmod(paridx) ...
                        spec{runidx}{condidx}.param(paridx) ];
                end
            end

            if isfield(spec{1}{condidx}, 'dur')
                matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx).duration = ...
                    [ matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx).duration ...
                    spec{runidx}{condidx}.dur ];
            else
                matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(condidx).duration = ...
                    0;
            end
        
        end
        
    end
        
    % Load data
    scans = volseq(data, true);
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = scans;
    
    % Get constant regressors
    cregs = getconstreg(length(data), length(scans) / length(data));
    
    if CCN.model.rpreg
    
        % Get motion regressors
        mpregs = getmotreg(rpfiles);
        
    else
        
        mpregs = [];
        
    end
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress = [mpregs cregs];
    
end

spmmat = sprintf('%s/SPM.mat', adir);

% Estimation
if isfield(CCN.model, 'est')
    if CCN.model.est
        matlabbatch{2}.spm.stats.fmri_est.spmmat = ...
            {spmmat};
    end
end

% Run job
spm_jobman('run', matlabbatch(1));

if isfield(CCN.model, 'thresh')
    load(spmmat);
    SPM.xM.T = SPM.xM.T .* CCN.model.thresh;
    SPM.xM.TH = SPM.xM.TH .* CCN.model.thresh;
    save(spmmat, 'SPM');
end

% Run job
spm_jobman('run', matlabbatch(2));

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
    
    for regidx = 1 : size(rpdata, 2)
        regs(regidx).name = names{regidx};
        regs(regidx).val = rpdata(:, regidx);
    end
    
end

function regs = getconstreg(nruns, nvols)
    
    const = [];
    
    for runidx = 1 : nruns
        const = blkdiag(const, ones(nvols, 1));
    end
    
    for regidx = 1 : (nruns - 1)
        regs(regidx).name = sprintf('const s%d', regidx);
        regs(regidx).val = const(:, regidx);
    end
    
end

end
