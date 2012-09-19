function contrast_b

global CCN;
clear matlabbatch;

% Get SPM.mat
spmmat = sprintf('%s/SPM.mat', expandpath(CCN.model.model_dir, false, 1));
matlabbatch{1}.spm.stats.con.spmmat = {spmmat};

% Set parameters
if ~isfield(CCN.contr, 'overwrite')
    matlabbatch{1}.spm.stats.con.delete = 1;
else
    matlabbatch{1}.spm.stats.con.delete = CCN.contr.overwrite;
end

% Get regressor names
load(spmmat);
names = cell(length(SPM.xX.name), 1);
if strcmp(CCN.model.basis, 'hrf')
    if isfield(CCN.contr, 'splitsess') && ...
            CCN.contr.splitsess
        regpat = '(Sn\(\d\) .*?)(?:\*bf\(\d\))?$';
    else
        regpat = 'Sn\(\d\) (.*?)(?:\*bf\(\d\))?$';
    end
elseif strcmp(CCN.model.basis, 'fir')
    if isfield(CCN.contr, 'splitsess') && ...
            CCN.contr.splitsess
        regpat = '(Sn\(\d\) .*)';
    else
        regpat = 'Sn\(\d\) (.*)';
    end
end
tokens = regexp(SPM.xX.name, regpat, 'tokens');
for tokidx = 1 : length(tokens)
    if ~isempty(tokens{tokidx})
        names{tokidx} = tokens{tokidx}{1}{1};
    else
        names{tokidx} = SPM.xX.name{tokidx};
    end
end

% Get F-contrast
fcon = zeros(length(CCN.contr.condnames), length(names));
for nameidx = 1 : length(CCN.contr.condnames)
    name = CCN.contr.condnames{nameidx};
    xmidx = ismember(names, name) .* ...
        (var(SPM.xX.xKXs.X) ~= 0)';
    fcon(nameidx, find(xmidx)) = 1; %#ok<FNDSB>
end
badrows = ~ any(fcon, 2);
fcon(badrows, :) = [];
matlabbatch{1}.spm.stats.con.consess{1}.fcon.name = 'fcon';
matlabbatch{1}.spm.stats.con.consess{1}.fcon.convec = {fcon};

% Get contrast vectors
contrnames = fieldnames(CCN.contr.contrs);

incidx = 1;
for contridx = 1 : length(contrnames)
    
    contrname = contrnames{contridx};
    contr = CCN.contr.contrs.(contrname);
    
    convec = zeros(size(names));
    for nameidx = 1 : length(CCN.contr.condnames)
        name = CCN.contr.condnames{nameidx};
        xmidx = ismember(names, name) .* ...
            (var(SPM.xX.xKXs.X) ~= 0)';
        if sum(xmidx) > 0
            convec = convec + contr(nameidx) * xmidx ./ sum(xmidx);
        end
    end
    
    if any(convec)
        matlabbatch{1}.spm.stats.con.consess{incidx + 1}.tcon.name = contrname;
        matlabbatch{1}.spm.stats.con.consess{incidx + 1}.tcon.convec = convec;
        incidx = incidx + 1;
    end
    
end

% Run job
spm_jobman('run', matlabbatch);