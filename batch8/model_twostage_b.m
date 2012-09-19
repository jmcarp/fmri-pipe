function model_twostage_b

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
[path name ext] = fileparts(specfile);
if strcmp(ext, '.mat')
    load(specfile);
elseif strcmp(ext, '.m')
    run(specfile);
end

% Load conditions

for runidx = 1 : length(spec)

    if ~isfield(CCN.model, 'hpf')
        matlabbatch{1}.spm.stats.fmri_spec.sess(runidx).hpf = ...
            spm_get_defaults('stats.fmri.hpf');
    else
        matlabbatch{1}.spm.stats.fmri_spec.sess(runidx).hpf = ...
            CCN.model.hpf;
    end

    % Load data
    matlabbatch{1}.spm.stats.fmri_spec.sess(runidx).scans = ...
        volseq(data{runidx}, true);

    % Get motion regressors
    regs = getmotreg(rpfiles(runidx));
    matlabbatch{1}.spm.stats.fmri_spec.sess(runidx).regress = regs;

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

CCN.model.rawresid = true;
CCN.model.saveresid = true;

spm_jobman('run', matlabbatch(2));

% Collect residuals
cmd = sprintf('fslmerge -t %s/ResI.nii %s/ResI*.img', ...
    adir, adir);
system(cmd);

% Clear SPM.mat
delete(spmmat);

%% 

for runidx = 1 : length(spec)

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
    
    % Clear motion regressors
    matlabbatch{1}.spm.stats.fmri_spec.sess(runidx).regress = [];
    
end

spm_jobman('run', matlabbatch(1));

if isfield(CCN.model, 'thresh')
    load(spmmat);
    SPM.xM.T = SPM.xM.T .* CCN.model.thresh;
    SPM.xM.TH = SPM.xM.TH .* CCN.model.thresh;
    save(spmmat, 'SPM');
end

% Run job
CCN.model.rawresid = false;
CCN.model.saveresid = false;
spm_jobman('run', matlabbatch(2));

%%

load(spmmat);
delete(spmmat);

if isfield(CCN.model, 'catruns') && CCN.model.catruns
    regpat = 'Sn\(\d+\)\s(.*?)\*bf\(\d+\)';
else
    regpat = '(Sn\(\d+\)\s.*?)\*bf\(\d+\)';
end

bfconds = struct();
bfregs = struct();

for nameidx = 1 : length(SPM.xX.name)

    tok = regexp(SPM.xX.name{nameidx}, ...
        regpat, 'tokens');
    if ~isempty(tok)
        cond = tok{1}{1};
        cond = regexprep(cond, '[\s\(\)]', '');
        if ~isfield(bfconds, cond)
            bfconds.(cond) = [];
        end
        bfconds.(cond) = [bfconds.(cond) nameidx];
    end

end

conds = fieldnames(bfconds);

for condidx = 1 : length(conds)

    cond = conds{condidx};
    bfregs(condidx).name = regexprep(cond, 'Sn\d+', '');
    bfregs(condidx).val = sum(SPM.xX.X(:, bfconds.(cond)), 2);

end

% Set filter
matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf = -inf;

% Set cvi
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'none';

% Clear onsets
matlabbatch{1}.spm.stats.fmri_spec.sess = [];

% Load data
scans = volseq(sprintf('%s/ResI.nii', adir), true);
matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = scans;

% Get constant regressors
cregs = getconstreg(length(data), length(scans) / length(data));

matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress = ...
    [bfregs cregs];

spm_jobman('run', matlabbatch(1));

if isfield(CCN.model, 'thresh')
    load(spmmat);
    SPM.xM.T = SPM.xM.T .* CCN.model.thresh;
    SPM.xM.TH = SPM.xM.TH .* CCN.model.thresh;
    save(spmmat, 'SPM');
end

% Run job
spm_jobman('run', matlabbatch(2));

% Delete residuals
delete(sprintf('%s/ResI.nii', adir));

%%

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