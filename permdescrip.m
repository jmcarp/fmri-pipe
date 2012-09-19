function permdescrip(permdir)

permdir = '/data00/jmcarp/data/open/ds008/permstat/sstopvsgo/l2';

meanname = sprintf('%s/permmean.img', permdir);
meanvol = spm_vol(meanname);
meanimg = spm_read_vols(meanvol);

rngname = sprintf('%s/permrng.img', permdir);
rngvol = spm_vol(rngname);
rngimg = spm_read_vols(rngvol);

minname = sprintf('%s/permmin.img', permdir);
minvol = spm_vol(minname);
minimg = spm_read_vols(minvol);

maxname = sprintf('%s/permmax.img', permdir);
maxvol = spm_vol(maxname);
maximg = spm_read_vols(maxvol);

minz = min(rngimg(:));
minind = find(rngimg == minz);
[x y z] = ind2sub(rngvol.dim, minind);
minminz = minimg(minind);
minminp = (1 - normcdf(minminz)) * 2;
maxminz = maximg(minind);
maxminp = (1 - normcdf(maxminz)) * 2;
mincoord = rngvol.mat * [x ; y ; z ; 1];
mincoord = mincoord(1 : 3)';
minlab = getlab(mincoord);
minlab = minlab{1};

fprintf('Min range value: %f\n', minz)
fprintf('\t%f, %f\n', minminz, minminp);
fprintf('\t%f, %f\n', maxminz, maxminp);
fprintf('%f, %f, %f\n', mincoord(1), mincoord(2), mincoord(3));
fprintf('%s\n', minlab);

maxz = max(rngimg(:));
maxind = find(rngimg == maxz);
[x y z] = ind2sub(rngvol.dim, maxind);
minmaxz = minimg(maxind);
minmaxp = (1 - normcdf(minmaxz)) * 2;
maxmaxz = maximg(maxind);
maxmaxp = (1 - normcdf(maxmaxz)) * 2;
maxcoord = rngvol.mat * [x ; y ; z ; 1];
maxcoord = maxcoord(1 : 3)';
maxlab = getlab(maxcoord);
maxlab = maxlab{1};

fprintf('Max range value: %f\n', minz)
fprintf('\t%f, %f\n', minmaxz, minmaxp);
fprintf('\t%f, %f\n', maxmaxz, maxmaxp);
fprintf('%f, %f, %f\n', maxcoord(1), maxcoord(2), maxcoord(3));
fprintf('%s\n', maxlab);
