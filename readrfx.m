function readrfx

global CCN;
if isempty(CCN)
    batchpar_008;
end

p = getpermlist;
env = getpenv(p, CCN);

[optlist optmat] = reclist(1, {}, {}, {}, p, env, CCN);
[optlist optmat contrlist p] = addcontr(optlist, optmat, p, env);

contrnames = fieldnames(CCN.contr.contrs);

% imtype = 'spmF';
tails = 2;
calcroi = false;
calcvox = true;
verbose = false;

roinames = [];
if isfield(CCN.roix, 'coord')
    roinames = [roinames ; fieldnames(CCN.roix.coord)];
else
    CCN.roix.coord = struct();
end
if isfield(CCN.roix, 'image')
    roinames = [roinames ; fieldnames(CCN.roix.image)];
end

% Build ROIs using MarsBar
maroi = struct();
for roiidx = 1 : length(roinames)
    roiname = roinames{roiidx};
    if isfield(CCN.roix.coord, roiname)
        if strcmp(CCN.roix.shape, 'sphere')
            for rowidx = 1 : size(CCN.roix.coord.(roiname), 1)
                roitmp = maroi_sphere(struct( ...
                    'centre', CCN.roix.coord.(roiname)(rowidx, :), ...
                    'radius', CCN.roix.radius));
                if rowidx == 1
                    maroi.(roiname) = roitmp;
                else
                    maroi.(roiname) = maroi.(roiname) | roitmp;
                end
            end
        elseif strcmp(CCN.roix.shape, 'box')
            maroi.(roiname) = maroi_box(struct( ...
                'centre', CCN.roix.coord.(roiname), ...
                'widths', CCN.roix.radius));
        end
    elseif isfield(CCN.roix.image, roiname)
        imgname = expandpath(CCN.roix.image.(roiname), ...
            false, 1);
        maroi.(roiname) = maroi_image(imgname);
    end
end

%%

% Initialize variables
con = struct();

mcorr = struct();

for contridx = 1 : length(contrnames)
    
    % Get contrast name
    contrname = contrnames{contridx};
    fprintf('Working on contrast %s...\n', contrname);
    
    % 
    fprintf('Progress:       ');
    
    imfiles = cell(length(optlist), 1);
    df = nan(length(optlist), 2);
    
    % 
    savdir = sprintf('%s/%s/l2', ...
        env.statdir, contrname);
    if ~exist(savdir, 'dir')
        mkdir(savdir);
    end
    
    for optidx = 1 : length(optlist)

        opts = optlist{optidx};
%         contrtype = 'Effects of Interest';

        contrtype = contrlist{optidx};
        if strcmp(contrtype, '+')
            cname = contrname;
%             imtype = 'spmT';
%             contrtype = sprintf('%s %s', contrtype, contrname);
        else
            cname = 'Main effect of basis';
%             imtype = 'spmF';
        end
        
        % Get SPM.mat
        spmdir = sprintf('%s/permrfx/%s/%s', ...
            CCN.root_dir, opts, contrname);
        spmmat = sprintf('%s/SPM.mat', spmdir);
        
        % Load SPM.mat
        load(spmmat);
        xnames = {SPM.xCon.name};
        xidx = find(ismember(xnames, cname), 1);
%         xidx = find(ismember(xnames, contrtype), 1);
        
        % Get spm* file
        imfiles{optidx} = sprintf('%s/%s', ...
            spmdir, SPM.xCon(xidx).Vspm.fname);
        imtype = sprintf('spm%s', SPM.xCon(xidx).STAT);
        
        % Get degrees of freedom
        df(optidx, 1) = round(SPM.xCon(xidx).eidf);
        df(optidx, 2) = round(SPM.xX.erdf);
        
        if calcroi
        
            % Build MarsBar design
            D = mardo(spmmat);
            
            for roiidx = 1 : length(roinames)

                % Get ROI
                roi = roinames{roiidx};

                % Estimate contrast
                if verbose
                    Y = get_marsy(maroi.(roi), D, 'mean');
                    E = estimate(D, Y);
                else
                    evalc('Y = get_marsy(maroi.(roi), D, ''mean'');');
                    evalc('E = estimate(D, Y);');
                end
                E = set_contrasts(E, SPM.xCon);
                contmp = compute_contrasts(E, xidx);
                
                % Get MarsBar stats
                con.(roi).stat(optidx, contridx) = contmp.stat;
                con.(roi).con(optidx, contridx) = contmp.con;
                con.(roi).pval(optidx, contridx) = contmp.P;
                
                basisidx = ismember(env.allsteps, 'basis');
                basisname = optmat{optidx, basisidx};
                switch basisname
                    case 'hrf'
                        tctmp = compute_contrasts(E, ...
                            length(xnames));
                    case 'inf'
                        tctmp = compute_contrasts(E, ...
                            length(xnames) - 2 : length(xnames));
                    case 'fir'
                        tctmp = compute_contrasts(E, ...
                            length(xnames) - 7 : length(xnames));
                    case 'cxb'
                        tctmp = compute_contrasts(E, ...
                            length(xnames) - 7 : length(xnames));
                end
                con.(roi).tc{optidx}(:, contridx) = tctmp.con;
                
                % Get z-scores
                if strcmp(imtype, 'spmF')
                    z1t = f2z(contmp.stat, df(optidx, 1), ...
                        df(optidx, 2), 1);
                    z2t = f2z(contmp.stat, df(optidx, 1), ...
                        df(optidx, 2), 2);
                    con.(roi).z1t(optidx, contridx) = z1t;
                    con.(roi).z2t(optidx, contridx) = z2t;
                end
                
            end
            
        end
        
        % 
        fprintf('\b\b\b\b\b\b%6.2f', optidx / length(optlist) * 100);
        
    end
    
    fprintf('\n');
    
    if ~calcvox
        continue
    end
    
    % Load images
    fprintf('\tLoading images...\n');
    vols = spm_vol(char(imfiles));
    imgs = spm_read_vols(vols);
    
    % Get Z-images
    fprintf('\tGetting Z-images...\n');
    for optidx = 1 : length(optlist)
        
        contrtype = contrlist{optidx};
        img = imgs(:, :, :, optidx);
        
        if strcmp(imtype, 'spmT')
            zimg = t2z(img, df(optidx, 2), tails);
        elseif strcmp(imtype, 'spmF')
            zimg = f2z(img, df(optidx, 1), df(optidx, 2), tails);
        end
        
        imgs(:, :, :, optidx) = zimg;
%         imgs(:, :, :, optidx) = f2z( ...
%             imgs(:, :, :, optidx), ...
%             df(optidx, 1), df(optidx, 2), 1 ...
%             );
        
    end
    
    % Initialize output volume
    outvol = vols(1);

    % Compute summary images
    fprintf('\tComputing summary images...\n');

    % Mean
    permmean = mean(imgs, 4);
    permmean(permmean == 0) = nan;
    
    % Variance
    permvar = var(imgs, [], 4);
    permvar(permvar == 0) = nan;
    
    % Range
    permmax = max(imgs, [], 4);
    permmax(permmax == 0) = nan;
    permmin = min(imgs, [], 4);
    permmin(permmin == 0) = nan;
    permrng = abs(max(imgs, [], 4) - min(imgs, [], 4));
    permrng(permrng == 0) = nan;

    % Save summary images

    % Mean
    outvol.fname = sprintf('%s/permmean.img', ...
        savdir);
    spm_write_vol(outvol, permmean);
    
    % Variance
    outvol.fname = sprintf('%s/permvar.img', ...
        savdir);
    spm_write_vol(outvol, permvar);
    
    % Range
    outvol.fname = sprintf('%s/permmax.img', ...
        savdir);
    spm_write_vol(outvol, permmax);
    outvol.fname = sprintf('%s/permmin.img', ...
        savdir);
    spm_write_vol(outvol, permmin);
    outvol.fname = sprintf('%s/permrng.img', ...
        savdir);
    spm_write_vol(outvol, permrng);
    
    % Get mean difference
    [~, mctmp] = calcmeandiff3d(vols, imgs, p, env, optmat, ...
        sprintf('%s/l2', contrname), true);
    mcorr.(contrname) = mctmp;
    
end

% Save ROI stats
confile = sprintf('%s/roicon', ...
    env.statdir);
if calcroi
    save(confile, 'con');
end

% Save ROI stats
if calcvox
    mcorrfile = sprintf('%s/mcorr_l2', ...
        env.statdir);
    save(mcorrfile, 'mcorr');
end