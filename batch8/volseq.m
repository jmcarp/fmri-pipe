function v = volseq(fnames, concat)

vols = spm_vol(fnames);

if iscell(vols)
    for cidx = 1 : length(vols)
        v{cidx} = getseq(vols{cidx});
    end
else
    v = {getseq(vols)};
end

if concat
    vtemp = {};
    for vidx = 1 : length(v)
        vtemp = cat(1, vtemp, v{vidx});
    end
    v = vtemp;
end

function s = getseq(vols)

s = cell(length(vols), 1);
for volidx = 1 : length(vols)
    s{volidx} = sprintf('%s,%d', vols(volidx).fname, volidx);
end