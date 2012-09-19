function batchpar

global CCN;
CCN = struct();

% CCN.steps = { 'despike_b' 'slice_b' 'realign_b' 'coregister_b' ...
%     'segment_b' 'norm_b' 'smooth_b' 'model_b' 'contrast_b' };
% CCN.steps = { 'model_b' 'contrast_b' };
CCN.steps = { 'rfx_b' };

CCN.root_dir   = '/data00/jmcarp/data/open/ds005';
CCN.psdir      = sprintf('%s/ps', CCN.root_dir);
CCN.logdir     = sprintf('%s/log', CCN.root_dir);
CCN.behavdir   = sprintf('%s/behav', CCN.root_dir);
CCN.specdir    = sprintf('%s/spec', CCN.root_dir);

CCN.run_pattern = 'task001_run00\\d';

CCN.rmold = true;

CCN.fdirs    = '[root_dir]/subjs/[subject]/BOLD/[run_pattern]$';
CCN.hrpat    = '[root_dir]/subjs/[subject]/anatomy\/highres\.nii$';
CCN.ovpat    = '[root_dir]/subjs/[subject]/anatomy\/inplane\.nii$';
CCN.ffiles   = '[root_dir]/subjs/[subject]/BOLD/[run_pattern]/[curr_pattern]';
CCN.meanpat  = '[root_dir]/subjs/[subject]/BOLD/[run_pattern]/meanadbold\.nii';
CCN.pspat    = '[psdir]/[csubject]_[step]';
CCN.subjpat  = '[root_dir]/subjs/sub\d{3}$';
CCN.rppat    = '[root_dir]/subjs/[subject]/BOLD/[run_pattern]/rp_adbold\.txt';

% Get subjects
CCN.subjs = expandpath(CCN.subjpat, true, inf, 3);

% CCN.subjs = CCN.subjs(1);

CCN.file_pattern = struct( ...
    'default',           'bold\\.nii', ... 
    'despike_b',         'bold\\.nii', ...
    'slice_b',           'dbold\\.nii', ...
    'realign_b',         'adbold\\.nii', ...
    'coregister_b',      'meanadbold\\.nii', ...
    'norm_b',            'adbold\\.nii', ...
    'smooth_b',          'wadbold\\.nii', ... 
    'hpf_b',             'swadbold\\.nii', ...
    'model_b',           'swadbold\\.nii', ...
    'model_twostage_b',  'swadbold\\.nii');
CCN.curr_pattern = CCN.file_pattern.default;

CCN.TR = 2.0;

CCN.despike.opts = '';
CCN.despike.skip = true;

% Slice order = [ 'asc' 'dsc' 'int' ]
% CCN.slice.seq = 'asc';
CCN.slice.seq = 'int';
% CCN.slice.seq = 'ctm';
% CCN.slice.seqvec = [ 21 : -2 : 1 20 : -2 : 2 ];
CCN.slice.skip = false;

CCN.realign = struct();

CCN.realign.unwarp = false;
CCN.realign.reslice = true;
CCN.realign.hrreg = true;

CCN.realign.uweopts = struct( ...
    'lambda', 100000, ...
    'fot', [4 5], ...
    'sot', [], ...
    'uwfwhm', 4 ...
    );

CCN.realign.uwropts = struct( ...
    'uwwhich', [2 1], ...
    'rinterp', 4, ...
    'wrap', [0 0 0], ...
    'mask', 1, ...
    'prefix', 'r' ...
    );

CCN.coreg.reslice = true;

% CCN.coreg.twostage = false;
CCN.coreg.twostage = true;

CCN.bet.opts = '-R';

CCN.seg.method = 'spm';

% CCN.norm.hrtemp = fullfile(spm('Dir'), 'templates', 'T1.nii');
% CCN.norm.hrtemp = fullfile(spm('Dir'), 'templates', 'T2.nii');
CCN.norm.hrtemp = '/data00/jmcarp/tools/templates/MNI152_T1_1mm_brain.nii';

% CCN.norm.normtype = 'func';
% CCN.norm.normtype = 'anat';
CCN.norm.normtype = 'seg';

CCN.norm.fwopts = struct( ...
    'vox', [3.125 3.125 4.0] ...
);

% CCN.norm.bet = false;
CCN.norm.prefix = 's';

CCN.norm.writenorm = true;
% CCN.norm.writenorm = false;

CCN.smooth.opts = struct(...
    'fwhm', [8 8 8] ...
    );

CCN.hpf.cutoff = 128;

% Full model
CCN.model.onset = true;

% Time units [ 'secs' | 'scans' ]
CCN.model.units = 'secs';

% Basis function [ 'hrf' | 'fir' ]
CCN.model.basis = 'hrf';
% CCN.model.basis = 'fir';

CCN.model.derivs = 'none';
% CCN.model.derivs = 'disp';

% CCN.model.length = 16;
% CCN.contr.expandbasis = true;

CCN.model.catruns = false;
% CCN.model.catruns = true;

CCN.model.thresh = -inf;
CCN.model.mask = fullfile(spm('dir'), 'apriori', 'brainmask_th125.nii');

% Global normalisation [ 'None' | 'Scaling' ]
CCN.model.global = 'None';
% CCN.model.global = 'Scaling';

% High-pass filter
CCN.model.hpf = 128;
% CCN.model.hpf = -inf;

% Serial correlations [ 'AR(1)' | 'none' ]
CCN.model.cvi = 'AR(1)';
% CCN.model.cvi = 'none';

CCN.model.spec_file = '[specdir]/spec_[subject].mat';

CCN.model.orth = true;

% Motion regressors [ true | false ]
CCN.model.rpreg = true;

% Motion regressor power expansion [ 1 ]
CCN.model.rppow = 1;
% Motion regressor spin history [ 0 ]
CCN.model.rpspin = 0;

CCN.model.model_dir = '[root_dir]/subjs/[subject]/analysis/model';

CCN.model.overwrite = true;

% Estimate model [ true | false ]
CCN.model.est = true;
% CCN.model.est = false;

CCN.contr.condnames = { ...
    'task' 'taskxgain^1' ...
    'taskxloss^1' ...
    };

CCN.contr.contrs = struct();

CCN.contr.contrs.task   = [ 1 0 0 ];
CCN.contr.contrs.gain   = [ 0 1 0 ];
CCN.contr.contrs.loss   = [ 0 0 1 ];

% CCN.roix.method = 'est';
CCN.roix.method = 'avg';
CCN.roix.savename = sprintf('%s/roix.mat', CCN.model.model_dir);

CCN.roix.image = struct();
CCN.roix.image.smg = '[root_dir]/roimask/smg.nii';
CCN.roix.image.rop = '[root_dir]/roimask/rop.nii';
CCN.roix.image.ins = '[root_dir]/roimask/ins.nii';

CCN.roix.coord = struct();
CCN.roix.shape = 'sphere';
CCN.roix.radius = 8;
% CCN.roix.coord.maxl1 = [
%     -54 -16   7
%      57 -13   7
%      ];
% CCN.roix.coord.maxl2 = [ 
%     -57 -25  13 
%      57 -22  10
%     ];
% CCN.roix.coord.vnt = [
%     -20 -38  16
%      20 -36  16
%     ];

CCN.modclean = struct();
CCN.modclean.cleanspm = true;
CCN.modclean.cleanbeta = true;
CCN.modclean.cleanspmt = false;
CCN.modclean.cleanspmf1 = true;
CCN.modclean.cleanspmf = true;
CCN.modclean.pack = false;

CCN.rfx.des = '1stt';
CCN.rfx.dir = '[root_dir]/rfx/model';
CCN.rfx.mtype = 'model';
