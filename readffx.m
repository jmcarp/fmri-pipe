function readffx

global CCN;
if isempty(CCN)
    batchpar_008;
end

p = getpermlist;
env = getpenv(p, CCN);

[optlist optmat] = reclist(1, {}, {}, {}, p, env, CCN);
% [optlist optmat contrlist p] = addcontr(optlist, optmat, p, env);

contrnames = fieldnames(CCN.contr.contrs);

imtype = 'spmF';

%%

% 
mcorr = struct();

for contridx = 1 : length(contrnames)

    contrname = contrnames{contridx};
    xidx = contridx + 1;
    
    fprintf('Working on contrast %s...\n', contrname);

    grppermmean = [];
    grppermvar = [];
    grppermrng = [];
    grpmeandiff = [];

    % Get group image directory
    grpsavdir = sprintf('%s/%s/l1/grp', ...
        env.statdir, contrname);
    if ~exist(grpsavdir, 'dir')
        mkdir(grpsavdir);
    end

    for subjidx = 1 : length(CCN.subjs)

        subj = CCN.subjs{subjidx};
        CCN.subject = subj;
        
        fprintf('\tWorking on subject %s...\n', subj);
        
        % Get subject image directory
        subjsavdir = sprintf('%s/%s/l1/%s', ...
            env.statdir, contrname, subj);
        if ~exist(subjsavdir, 'dir')
            mkdir(subjsavdir);
        end
        
        imfiles = cell(length(optlist), 1);
        df = nan(length(optlist), 2);
        
        for optidx = 1 : length(optlist)

            opts = optlist{optidx};

            % Get model directory
            CCN.model.model_dir = sprintf( ...
                '[root_dir]/subjs/[subject]/perm/model_%s', ...
                opts);
            mdir = expandpath(CCN.model.model_dir, false, 1);
            
            % Load model details
            mdfile = sprintf('%s/mdetail.mat', mdir);
            load(mdfile);

            % Get image file
            imfiles{optidx} = sprintf('%s/%s_%04d.img', ...
                mdir, imtype, xidx);

            % Get degrees of freedom
            df(optidx, 1) = round(mdetail.eidf(xidx));
            df(optidx, 2) = round(mdetail.erdf);
            
        end

        % Load images
        fprintf('\t\tLoading images...\n');
        vols = spm_vol(char(imfiles));
        imgs = spm_read_vols(vols);
        
        % Get Z-images
        fprintf('\t\tGetting Z-images...\n');
        for optidx = 1 : length(optlist)
            
            imgs(:, :, :, optidx) = f2z( ...
                imgs(:, :, :, optidx), ...
                df(optidx, 1), df(optidx, 2), 1 ...
                );
            
        end
        
        % Initialize output volume
        outvol = vols(1);
        
        % Compute summary images
        fprintf('\t\tComputing summary images...\n');
        
        % Mean
        permmean = mean(imgs, 4);
        permmean(permmean == 0) = nan;
        grppermmean(subjidx, :, :, :) = permmean;

        % Variance
        permvar = var(imgs, [], 4);
        permvar(permvar == 0) = nan;
        grppermvar(subjidx, :, :, :) = permvar;

        % Range
        permrng = abs(max(imgs, [], 4) - min(imgs, [], 4));
        permrng(permrng == 0) = nan;
        grppermrng(subjidx, :, :, :) = permrng;
        
        % Save summary images
        
        % Mean
        outvol.fname = sprintf('%s/permmean.img', ...
            subjsavdir);
        spm_write_vol(outvol, permmean);
        
        % Variance
        outvol.fname = sprintf('%s/permvar.img', ...
            subjsavdir);
        spm_write_vol(outvol, permvar);
        
        % Range
        outvol.fname = sprintf('%s/permrng.img', ...
            subjsavdir);
        spm_write_vol(outvol, permrng);
        
        % Get mean difference
        fprintf('\t\tComputing mean difference...\n');
        [mdtmp, mctmp] = calcmeandiff3d(vols, imgs, p, env, optmat, ...
            sprintf('%s/l2', contrname), true, subjsavdir);
        mcorr.(contrname)(subjidx, :) = mctmp;
        grpmeandiff(subjidx, :, :, :, :) = mdtmp;

    end
    
    % Compute group images
    meanpermmean = squeeze(mean(grppermmean));
    meanpermvar = squeeze(mean(grppermvar));
    meanpermrng = squeeze(mean(grppermrng));
    
    % Save group images
    outvol.fname = sprintf('%s/permmean.img', ...
        grpsavdir);
    spm_write_vol(outvol, meanpermmean);
    
    outvol.fname = sprintf('%s/permvar.img', ...
        grpsavdir);
    spm_write_vol(outvol, meanpermvar);
    
    outvol.fname = sprintf('%s/permrng.img', ...
        grpsavdir);
    spm_write_vol(outvol, meanpermrng);
    
    % Save mean difference images
    meanmeandiff = squeeze(mean(grpmeandiff));
    
    for stepidx = 1 : length(env.allsteps)
        
        stepname = env.allsteps{stepidx};

        % Check step values
        if ismember(stepname, env.procsteps)
            stepvals = fieldnames(p.proc.(stepname));
        elseif ismember(stepname, env.modelsteps)
            stepvals = fieldnames(p.model.(stepname));
        end
        if length(stepvals) == 1
            continue
        end

        % 
        mdstep = squeeze(meanmeandiff(:, :, :, stepidx));
        
        % 
        outvol.fname = sprintf('%s/md_%s.img', ...
            grpsavdir, stepname);
        spm_write_vol(outvol, mdstep);
        
    end
    
end

% Save ROI stats
mcorrfile = sprintf('%s/mcorr_l1', ...
    env.statdir);
save(mcorrfile, 'mcorr');