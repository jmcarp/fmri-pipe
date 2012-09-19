function outname = savespm(spmmat, calcspm, stat, u, k, conidx, method, apptxt, capture)

% Load SPM
if isstruct(spmmat)
    SPM = spmmat;
else
    load(spmmat);
end

% Initialize xSPM
xSPM = struct();

% SPM directory
xSPM.swd = SPM.swd;

% Choose t-map
xSPM.STAT = stat;

% Misc
xSPM.Im = [];
xSPM.pm = [];

% Threshold method
xSPM.thresDesc = method;

% Height threshold
xSPM.df = [SPM.xCon(conidx).eidf SPM.xX.erdf];
xSPM.u = u;

% Extent threshold
xSPM.k = k;

% Contrast index
xSPM.Ic = conidx;
xSPM.title = SPM.xCon(conidx).name;

% Get output name
outname = sprintf('%s/%s%s.img', SPM.swd, ...
    regexprep(xSPM.title, '[\s]', ''), apptxt);

if calcspm
    
    % Get thresholded SPM
    if capture
        evalc('[~, xSPM] = spm_getSPM(xSPM)');
    else
        [~, xSPM] = spm_getSPM(xSPM);
    end

    % Write thresholded SPM
    if capture
        evalc(['spm_write_filtered(xSPM.Z, xSPM.XYZ, xSPM.DIM, ' ...
            'xSPM.M, xSPM.title, outname)']);
    else
        spm_write_filtered(xSPM.Z, xSPM.XYZ, xSPM.DIM, ...
            xSPM.M, xSPM.title, outname);
    end
    
end

outvol = spm_vol(outname);
outimg = spm_read_vols(outvol);

df1 = round(SPM.xCon(conidx).eidf);
df2 = round(SPM.xX.erdf);

zoutimg = f2z(outimg, df1, df2, 2);
outvol.fname = fileprep(outvol.fname, 'z');
spm_write_vol(outvol, zoutimg);