function hpf_b

global CCN;

% Load data
data = expandpath(CCN.ffiles);

for runidx = 1 : length(data)
    
    runname = data{runidx};
    outname = fileprep(runname, 'f');
    
    % Filter data
    cmd = sprintf('fslmaths %s -bptf %d -1 %s', ...
        runname, CCN.hpf.cutoff / CCN.TR, outname);
    system(cmd);
    
    % Unarchive filtered data
    cmd = sprintf('gunzip -f %s.gz', outname);
    system(cmd);
    
end