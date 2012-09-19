function permthresh

global CCN;
if isempty(CCN)
    batchpar_008;
end

p = getpermlist;
env = getpenv(p, CCN);

[optlist optmat] = reclist(1, {}, {}, {}, p, env, CCN);
[optlist optmat contrlist p] = addcontr(optlist, optmat, p, env);

niter = 10000;
% overwrite = true;
overwrite = false;
clust = alphasim_perm(niter, overwrite);

contrnames = fieldnames(CCN.contr.contrs);

% calcspm = true;
calcspm = false;

pthrs = [ 0.01 0.001 0.0001 ];
env.u = struct( ...
    'fdr', 0.05, ...
    'fwe', 0.05 ...
    );
% env.k = struct( ...
%     'fdr', 10, ...
%     'fwe', 10 ...
%     );
% Omit extent thresholds based on
%   Frontiers reviews
env.k = struct( ...
    'fdr', 0, ...
    'fwe', 0 ...
    );

thrnames = { 'as_pe2' 'as_pe3' 'as_pe4' 'fdr' 'fwe' };
nthresh = length(thrnames);

smoothidx = ismember(env.allsteps, 'smooth');

spmf0 = sprintf('%s/permrfx/%s/%s/spmF_0003.img', ...
    CCN.root_dir, optlist{1}, contrnames{1});
vol0 = spm_vol(spmf0);

% Initialize voxel summary
voxprop = nan(length(contrnames), length(optlist) * nthresh, 1);
sumvoxprop = nan(length(contrnames), nthresh + 1);

for contridx = 5%1 : length(contrnames)

    % Get contrast name
    contrname = contrnames{contridx};
    fprintf('Working on contrast %s...\n', contrname);
    
    % Initialize progress bar
    fprintf('Progress:       ');
    
    % 
    savdir = sprintf('%s/%s/l2', ...
        env.statdir, contrname);
    if ~exist(savdir, 'dir')
        mkdir(savdir);
    end
    
    % Initialize variables
    sigimgs = false( ...
        vol0.dim(1), vol0.dim(2), vol0.dim(3), ...
        length(optlist) * nthresh ...
    );
    thrtypes = cell(length(optlist) * nthresh, 1);
    ctidx = 1;
    
    for optidx = 1 : length(optlist)
        
        opts = optlist{optidx};
        
        contrtype = contrlist{optidx};
%         if strcmp(contrtype, '+')
%             cname = contrname;
%         else
%             cname = 'Main effect of basis';
%         end
        
        % Get SPM.mat
        spmdir = sprintf('%s/permrfx/%s/%s', ...
            CCN.root_dir, opts, contrname);
        spmmat = sprintf('%s/SPM.mat', spmdir);
        
        % Load SPM.mat
        load(spmmat);
%         xnames = {SPM.xCon.name};
%         xidx = find(ismember(xnames, cname), 1);
%         xidx = find(ismember(xnames, contrtype), 1);
        
        xidx = getxconidx(SPM, contrname, contrtype);
        
        % Get brain voxels
        bvidx = 1;
        while true
            conname = sprintf('%s/con_%04d.img', spmdir, bvidx);
            if exist(conname, 'file')
                break
            end
            bvidx = bvidx + 1;
        end
        conimg = spm_read_vols(spm_vol(conname));
        nvox = sum(~isnan(conimg(:)));
        
        % AlphaSim thresholds
        for pidx = 1 : length(pthrs)
            
            % Get height threshold
            u = pthrs(pidx);
            plog = -log10(u);
            
            % Get extent threshold
            smoothopt = optmat{optidx, smoothidx};
            asfield = sprintf('pe%d_%s', plog, smoothopt);
            k = clust.(asfield);
            
            apptxt = sprintf('as_pe%d', plog);
            
            % Save thresholded image
            tname = savespm(SPM, calcspm, 'F', u, k, xidx, ...
                'none', ['_' apptxt], true);
            
            thrtypes{ctidx} = apptxt;
            sigimg = logical(spm_read_vols(spm_vol(tname)));
            sigimgs(:, :, :, ctidx) = sigimg;
            voxprop(contridx, ctidx) = sum(sigimg(:)) / nvox;
            ctidx = ctidx + 1;
            
        end
        
        % FDR threshold
        tname = savespm(SPM, calcspm, 'F', env.u.fwe, env.k.fdr, ...
            xidx, 'FDR', '_fdr', true);
        thrtypes{ctidx} = 'fdr';
        sigimg = logical(spm_read_vols(spm_vol(tname)));
        sigimgs(:, :, :, ctidx) = sigimg;
        voxprop(contridx, ctidx) = sum(sigimg(:)) / nvox;
        ctidx = ctidx + 1;
        
        % FWE threshold
        tname = savespm(SPM, calcspm, 'F', env.u.fdr, env.k.fdr, ...
            xidx, 'FWE', '_fwe', true);
        thrtypes{ctidx} = 'fwe';
        sigimg = logical(spm_read_vols(spm_vol(tname)));
        sigimgs(:, :, :, ctidx) = sigimg;
        voxprop(contridx, ctidx) = sum(sigimg(:)) / nvox;
        ctidx = ctidx + 1;
        
        % Update progress
        fprintf('\b\b\b\b\b\b%6.2f', ...
            optidx / length(optlist) * 100);
        
    end
    
    % 
    fprintf('\n');
    
    % Summarize significance images
    
    % 
    for thridx = 1 : length(thrnames)
        
        thrname = thrnames{thridx};
        
        sigidx = ismember(thrtypes, thrname);
        sigsum = sum(sigimgs(:, :, :, sigidx), 4);
        
        % Write proportion significant
        sigprop = sigsum ./ sum(sigidx);
        vol0.fname = sprintf('%s/sig_prop_%s.img', ...
            savdir, thrname);
        spm_write_vol(vol0, sigprop);
        
        % Write disagreement
        disagree = min(sigprop, 1 - sigprop);
        vol0.fname = sprintf('%s/sig_disagree_%s.img', ...
            savdir, thrname);
        spm_write_vol(vol0, disagree);
        
        % Update voxel summary
        sumvoxprop(contridx, thridx) = sum(voxprop(contridx, sigidx)) / sum(sigidx);
        
    end
    
    sigsum = sum(sigimgs, 4);
    
    % Write proportion significant
    sigprop = sigsum ./ size(sigimgs, 4);
    vol0.fname = sprintf('%s/sig_prop.img', ...
        savdir);
    spm_write_vol(vol0, sigprop);
    
    % Write disagreement
    disagree = min(sigprop, 1 - sigprop);
    vol0.fname = sprintf('%s/sig_disagree.img', ...
        savdir);
    spm_write_vol(vol0, disagree);
    
    % Update voxel summary
    sumvoxprop(contridx, thridx + 1) = sum(voxprop(contridx, :)) / size(sigimgs, 4);
    
end

% Save voxel summary
voxfile = sprintf('%s/sumvox', ...
    env.statdir);
save(voxfile, 'voxprop', 'sumvoxprop', 'thrtypes');
