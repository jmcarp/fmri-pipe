function clust = alphasim_perm(niter, overwrite)

global CCN;

rmm = 5;
% niter = 1000;
clup = 0.05;

asdir = sprintf('%s/alphasim', CCN.root_dir);
maskname = sprintf('%s/rbrainmask_th125.nii', ...
    asdir);

kernels = 4 : 4 : 12;
pthrs = [ 0.01 0.001 0.0001 ];

clust = struct();

for pidx = 1 : length(pthrs)
    
    pval = pthrs(pidx);
    plog = -log10(pval);
    
    for kidx = 1 : length(kernels)

        kval = kernels(kidx);
        outname = sprintf('rest_pe%d_sk%d', ...
            plog, kval);
        outfull = sprintf('%s/%s.txt', ...
            asdir, outname);
        
        if ~ exist(outfull, 'file') || overwrite
            
            rest_AlphaSim(maskname, asdir, ...
                outname, rmm, kval, pval, niter);
            
        end
        
        % Load AlphaSim output
        asdata = dlmread(outfull, '\t', 20, 0);
        alpha = asdata(:, end);
        sigidx = find(alpha <= clup, 1);
        cstmp = asdata(sigidx, 1);
        
        asfield = sprintf('pe%d_fwhm%d', plog, kval);
        clust.(asfield) = cstmp;
        
    end
    
end