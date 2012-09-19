function [mmpeak voxpeak] = getspmpeak(spmmat, contridx, varargin)

% 
if nargin > 2
    maskfiles = varargin{1};
end

spmdir = fileparts(spmmat);
load(spmmat);

xyzmm = SPM.xVol.M(1 : 3, :) * ...
    [SPM.xVol.XYZ ; ones(1, SPM.xVol.S)];

confile = sprintf('%s/%s', ...
    spmdir, SPM.xCon(contridx).Vspm.fname);
convol = spm_vol(confile);
conimg = spm_read_vols(convol);

% 
voxfile = sprintf('%s/mask.img', spmdir);
voxvol = spm_vol(voxfile);
voximg = spm_read_vols(voxvol);

flat = @(x) x(:);

if exist('maskfiles', 'var')
    
    for maskidx = 1 : length(maskfiles)
        
        maskfile = maskfiles{maskidx};
        spm_mask(maskfile, confile);
        
        [~, name] = fileparts(confile);
        mconfile = sprintf('%s/m%s.img', pwd, name);
%         mconfile = fileprep(confile, 'm');
        mconvol = spm_vol(mconfile);
        mconimg = spm_read_vols(mconvol);
        
        peakval = max(flat(mconimg));
        peakidx = find(mconimg(voximg ~= 0) == peakval, 1);
        mmpeak(maskidx, :) = xyzmm(:, peakidx);
        voxpeak(maskidx, :) = SPM.xVol.XYZ(:, peakidx);
        
    end
    
else
    
    % 
    halfx = convol.dim(2) / 2;
    
    % 
    peakval = max(flat(conimg(1 : floor(halfx), :, :)));
    peakidx = find(conimg(voximg ~= 0) == peakval, 1);
    mmpeak(1, :) = xyzmm(:, peakidx);
    voxpeak(1, :) = SPM.xVol.XYZ(:, peakidx);
    
    % 
    peakval = max(flat(conimg(ceil(halfx) : end, :, :)));
    peakidx = find(conimg(voximg ~= 0) == peakval, 1);
    mmpeak(2, :) = xyzmm(:, peakidx);
    voxpeak(2, :) = SPM.xVol.XYZ(:, peakidx);
    
end