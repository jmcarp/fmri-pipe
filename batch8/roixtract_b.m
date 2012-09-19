function roixtract_b

global CCN;

global roiact;
roiact = struct();

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
            maroi.(roiname) = maroi_sphere(struct( ...
                'centre', CCN.roix.coord.(roiname), ...
                'radius', CCN.roix.radius));
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

for subjidx = 1 : length(CCN.subjs)
    
    subj = CCN.subjs{subjidx};
    CCN.subject = subj;
    
    spmdir = expandpath(CCN.model.model_dir, false, 1);
    spmmat = sprintf('%s/SPM.mat', spmdir);
    
%     if strcmp(CCN.roix.method, 'est')
        D = mardo(spmmat);
%         D = autocorr(D, 'none');
%         D = autocorr(D, 'fmristat', 1);
%     end
    
    xSPM = load(spmmat);
    xCon = xSPM.SPM.xCon;
    xnames = {xCon.name};
    
    for roiidx = 1 : length(roinames)
        
        roiname = roinames{roiidx};
        
%         if strcmp(CCN.roix.method, 'est')
        try
            Y = get_marsy(maroi.(roiname), D, 'mean');
            E = estimate(D, Y);
            E = set_contrasts(E, xCon);
        catch, end   
%         end

        for xidx = 1 : length(xnames)
            
            xname = xnames{xidx};
                
%             if strcmp(CCN.roix.method, 'avg')
                
                xfile = sprintf('%s/%s', expandpath(CCN.model.model_dir, false, 1), ...
                    xCon(xidx).Vcon.fname);
                
                act = summary_data(get_marsy(maroi.(roiname), ...
                    repmat(spm_vol(xfile), 2, 1), 'mean'));
                roiact.avg.(roiname).(xname)(subjidx) = act(1);
                
%             elseif strcmp(CCN.roix.method, 'est')
            try
                con = compute_contrasts(E, xidx);
                roiact.est.(roiname).(xname)(subjidx) = con;
            catch, end
%             end
            
        end
        
    end
    
end

% Save results
if isfield(CCN.roix, 'savename')
    savename = expandpath(CCN.roix.savename, false, 1);
    save(savename, 'roiact', 'CCN');
end
