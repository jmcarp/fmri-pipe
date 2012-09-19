function slice_b

global CCN;
clear matlabbatch;

% Get files
data = expandpath(CCN.ffiles);

% Remove old files
rmold(data, 'a');

% Skip if requested
if isfield(CCN.slice, 'skip') && ...
        CCN.slice.skip == true
    for runidx = 1 : length(data)
        oldname = data{runidx};
        newname = fileprep(oldname, 'a');
        niicopy(oldname, newname);
%         copyfile(oldname, newname);
    end
    return
end

% Get nslic
vol = spm_vol(data{1});
if length(vol) > 1
    vol = vol(1);
end
nslic = vol.dim(3);

% Get slice order
switch CCN.slice.seq
    case 'asc'
        seq = 1 : nslic;
    case 'dsc'
        seq = nslic : -1 : 1;
    case 'int'
        seq = [1 : 2 : nslic 2 : 2 : nslic];
    case 'siemens'
        odds = 1 : 2 : nslic;
        evens = 2 : 2 : nslic;
        if mod(nslic, 2) == 0
            seq = [evens odds];
        else
            seq = [odds evens];
        end
    case 'ctm'
        seq = CCN.slice.seqvec;
end

% Setup matlabbatch
matlabbatch{1}.spm.temporal.st = spm_get_defaults('slicetiming');
matlabbatch{1}.spm.temporal.st.scans = volseq(data, false);
matlabbatch{1}.spm.temporal.st.nslices = nslic;
matlabbatch{1}.spm.temporal.st.tr = CCN.TR;
matlabbatch{1}.spm.temporal.st.ta = CCN.TR - CCN.TR / nslic;
matlabbatch{1}.spm.temporal.st.so = seq';
matlabbatch{1}.spm.temporal.st.refslice = 1;

% Run matlabbatch
spm_jobman('run', matlabbatch);