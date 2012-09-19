function [so doreslice] = permso(fname, mname, sname, ...
    slices, erodim, outname, varargin)

% Get optional arguments
if nargin > 6
    zlim = varargin{1};
end
if nargin > 7
    doreslice = varargin{2};
else
    doreslice = true;
end

% Reslice to structural
if doreslice
    spm_reslice({sname mname fname});
end

% Load functional
rfname = fileprep(fname, 'r');
rfvol = spm_vol(rfname);
rfimg = spm_read_vols(rfvol);

% Load mask
rmname = fileprep(mname, 'r');
rmvol = spm_vol(rmname);
rmimg = spm_read_vols(rmvol);

% Erode mask
if erodim > 0
    se = strel('disk', erodim);
    rmimg = imerode(rmimg, se);
end

% Apply mask
rfimg(rmimg == 0) = nan;
spm_write_vol(rfvol, rfimg);

% Build overlay
so = slover(spm_vol(char({rfname sname})));
so.img(1).type = 'truecolor';
so.img(1).cmap = jet;
so.img(2).range = [78 7616];
so.slices = slices;
so.cbar = 1;
so.labels.size = 0.125;
if (exist('zlim', 'var') && isnumeric(zlim))
    so.img(1).range = zlim;
else
    so.img(1).range = [0 0];
end

% Draw overlay
so = paint(so);

% Save so to mat file
save(outname, 'so');

% Print to file
style = hgexport('readstyle', 'expstyle');
hgexport(gcf, [outname '.pdf'], style);
% so.printstr = 'print -dpdf -painters -noui';
% so.printfile = outname;
% print_fig(so);

% Unset doreslice
doreslice = false;
% doreslice = true;