function contrast_mod_b

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
if strcmp(CCN.model.basis, 'hrf') && ...
        strcmp(CCN.model.derivs, 'none')
    if isfield(CCN.contr, 'splitsess') && ...
            CCN.contr.splitsess
        regpat = '(Sn\(\d\) .*?)(?:\*bf\(\d\))?$';
    else
        regpat = 'Sn\(\d\) (.*?)(?:\*bf\(\d\))?$';
    end
else
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
    runtok = regexp(SPM.xX.name{tokidx}, 'Sn\((\d)\)', 'tokens');
    runs(tokidx) = str2double(runtok{1}{1});
end

if isfield(CCN.contr, 'skippartial') && ...
        CCN.contr.skippartial == true
    uruns = unique(runs);
    for runidx = 1 : length(uruns)
        cols = find(runs == uruns(runidx));
        if ~all(ismember(CCN.contr.condnames, ...
                names(cols)))
            for col = cols
                names{col} = sprintf('bad%s', names{col});
            end
        end
    end
end

% Get contrast vectors
contrnames = fieldnames(CCN.contr.contrs);

if strcmp(CCN.model.basis, 'hrf')
    switch CCN.model.derivs
        case 'none'
            nbasis = 1;
        case 'time'
            nbasis = 2;
        case 'disp'
            nbasis = 3;
    end
elseif strcmp(CCN.model.basis, 'fir')
    nbasis = CCN.model.length / CCN.TR;
end

% Get F-contrast
% if ~isfield(CCN.contr, 'expandbasis') || ...
%         CCN.contr.expandbasis == false
if strcmp(CCN.model.basis, 'hrf')
    
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
    
    incidx = 1;
    
else
    
    fcon = zeros(length(CCN.contr.condnames) * nbasis, ...
        length(names));
    rowidx = 0;
    
    for nameidx = 1 : length(CCN.contr.condnames)
        
        for basisidx = 1 : nbasis
            
            rowidx = rowidx + 1;
            
            name = sprintf('%s*bf(%d)', ...
                CCN.contr.condnames{nameidx}, basisidx);
            xmidx = ismember(names, name) .* ...
                (var(SPM.xX.xKXs.X) ~= 0)';
            fcon(rowidx, find(xmidx)) = 1; %#ok<FNDSB>

        end
        
    end
    
    badrows = ~ any(fcon, 2);
    fcon(badrows, :) = [];
    matlabbatch{1}.spm.stats.con.consess{1}.fcon.name = 'fcon';
    matlabbatch{1}.spm.stats.con.consess{1}.fcon.convec = {fcon};
        
    incidx = 1;
    
end

for contridx = 1 : length(contrnames)
    
%     if isfield(CCN.contr, 'expandbasis') && ...
%             CCN.contr.expandbasis == true
    if ~strcmp(CCN.model.basis, 'hrf')
        
        contrname = contrnames{contridx};
        contr = CCN.contr.contrs.(contrname);
        
%         fcon = zeros(length(CCN.contr.condnames) * nbasis, ...
%             length(names));
%         rowidx = 0;
        
        for basisidx = 1 : nbasis
                
            convec = zeros(size(names));
            for nameidx = 1 : length(CCN.contr.condnames)
                
                name = sprintf('%s*bf(%d)', ...
                    CCN.contr.condnames{nameidx}, basisidx);
                xmidx = ismember(names, name) .* ...
                    (var(SPM.xX.xKXs.X) ~= 0)';
                if sum(xmidx) > 0
                    convec = convec + contr(nameidx) * xmidx ./ sum(xmidx);
                end
                
            end
            
            if any(convec)
                matlabbatch{1}.spm.stats.con.consess{incidx + 1}.tcon.name = ...
                    sprintf('%s_basis%d', contrname, basisidx);
                matlabbatch{1}.spm.stats.con.consess{incidx + 1}.tcon.convec = convec;
                incidx = incidx + 1;
%                 rowidx = rowidx + 1;
%                 fcon(rowidx, :) = convec;
            end
            
        end
        
%         badrows = ~ any(fcon, 2);
%         fcon(badrows, :) = [];
%         matlabbatch{1}.spm.stats.con.consess{contridx + 1}.fcon.name = sprintf( ...
%             'fcon_%s', contrname);
%         matlabbatch{1}.spm.stats.con.consess{contridx + 1}.fcon.convec = {fcon};
    
    else
        
        if ~strcmp(CCN.model.basis, 'hrf')
            continue
        end
        
        contrname = contrnames{contridx};
        contr = CCN.contr.contrs.(contrname);

        convec = zeros(size(names));
        for nameidx = 1 : length(CCN.contr.condnames)
            name = CCN.contr.condnames{nameidx};
            if isfield(CCN.contr, 'scale') && ...
                    CCN.contr.scale == true
                xmidx = ismember(names, name) .* ...
                    (var(SPM.xX.xKXs.X) ~= 0)';
                if sum(xmidx) > 0
                    convec = convec + contr(nameidx) * xmidx ./ sum(xmidx);
                end
            else
                convec = convec + contr(nameidx) * ismember(names, name);
            end
        end

        if any(convec)
            matlabbatch{1}.spm.stats.con.consess{incidx + 1}.tcon.name = contrname;
            matlabbatch{1}.spm.stats.con.consess{incidx + 1}.tcon.convec = convec;
            incidx = incidx + 1;
        end
        
    end
    
end

if isfield(CCN.contr, 'basis') && nbasis > 1
    
    basistypes = fieldnames(CCN.contr.basis);

    for contridx = 1 : length(contrnames)

        contrname = contrnames{contridx};
        contr = CCN.contr.contrs.(contrname);

        for btypeidx = 1 : length(basistypes)

            btype = basistypes{btypeidx};
            bvec = CCN.contr.basis.(btype);
            
            convec = zeros(size(names));
            
            for basisidx = 1 : nbasis
                
                bmult = bvec(basisidx);
                
                if bmult == 0
                    continue
                end

                for nameidx = 1 : length(CCN.contr.condnames)

                    name = sprintf('%s*bf(%d)', ...
                        CCN.contr.condnames{nameidx}, basisidx);
                    xmidx = ismember(names, name) .* ...
                        (var(SPM.xX.xKXs.X) ~= 0)';
                    if sum(xmidx) > 0
                        convec = convec + bmult * contr(nameidx) * xmidx ./ sum(xmidx);
                    end

                end
                
            end
            
            if any(convec)
                ncontr = length(matlabbatch{1}.spm.stats.con.consess);
                matlabbatch{1}.spm.stats.con.consess{ncontr + 1}.tcon.name = ...
                    sprintf('%s_basis%s', contrname, btype);
                matlabbatch{1}.spm.stats.con.consess{ncontr + 1}.tcon.convec = convec;
%                 matlabbatch{1}.spm.stats.con.consess{incidx + length(contrnames) + 1}.tcon.name = ...
%                     sprintf('%s_basis_%s', contrname, btype);
%                 matlabbatch{1}.spm.stats.con.consess{incidx + length(contrnames) + 1}.tcon.convec = convec;
                incidx = incidx + 1;
            end

        end
        
    end
    
end

% Run job
spm_jobman('run', matlabbatch);

%% Save model details

spmdir = expandpath(CCN.model.model_dir, false, 1);
spmmat = sprintf('%s/SPM.mat', spmdir);
load(spmmat)

mdetail = struct();
mdetail.rnames = SPM.xX.name;
mdetail.cnames = {SPM.xCon.name};
mdetail.erdf = SPM.xX.erdf;
mdetail.eidf = [SPM.xCon.eidf];
mdetail.stat = {SPM.xCon.STAT}; %#ok<STRNU>

mdname = sprintf('%s/mdetail.mat', spmdir);
save(mdname, 'mdetail');

%% Normalize results

if isfield(CCN, 'normmodorder') && ...
        strcmp(CCN.normmodorder.first, 'modfirst')
    
    fwopts = spm_get_defaults('normalise.write');
    if isfield(CCN.norm, 'fwopts')
        fwopts = catstruct(fwopts, CCN.norm.fwopts);
    end
    
    if isfield(CCN, 'hrpat')
        hrfile = expandpath(CCN.hrpat, false, 1);
        if ~isfield(CCN.norm, 'prefix')
            prefix = 'reg';
        else
            prefix = sprintf('%sreg', CCN.norm.prefix);
        end
        [path name] = fileparts(hrfile);
    end

    if strcmp(CCN.norm.normtype, 'func')

        srcfile = expandpath(CCN.meanpat, false, 1);
        [srcpath srcname] = fileparts(srcfile);
        matname = sprintf('%s/%s_sn.mat', srcpath, srcname);

    elseif strcmp(CCN.norm.normtype, 'anat')

        matname = sprintf('%s/%s%s_sn.mat', path, prefix, name);

    elseif strcmp(CCN.norm.normtype, 'seg')

        matname = sprintf('%s/reg%s_seg_sn.mat', path, name);
        
    end
    
    betfiles = {};
    for betidx = 1 : length(SPM.Vbeta)
        betfiles{betidx} = sprintf('%s/%s', ...
            SPM.swd, SPM.Vbeta(betidx).fname);
    end
    
    confiles = {}; statfiles = {};
    for conidx = 1 : length(SPM.xCon)
        confiles{conidx} = sprintf('%s/%s', ...
            SPM.swd, SPM.xCon(conidx).Vcon.fname);
        statfiles{conidx} = sprintf('%s/%s', ...
            SPM.swd, SPM.xCon(conidx).Vspm.fname);
    end
    
    normfiles = [betfiles confiles statfiles];
    
    clear matlabbatch;
    
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample = ...
        volseq(normfiles, true);
    matlabbatch{1}.spm.spatial.normalise.write.subj.matname = ...
        {matname};
    matlabbatch{1}.spm.spatial.normalise.write.roptions = fwopts;
    
    spm_jobman('run', matlabbatch);
    
    % Rename normalized files
    
    for fileidx = 1 : length(normfiles)
        
        preimgfile = normfiles{fileidx};
        postimgfile = fileprep(preimgfile, 'w');
        
        prehdrfile = chext(preimgfile, '.hdr');
        posthdrfile = chext(postimgfile, '.hdr');
        
        copyfile(postimgfile, preimgfile, 'f');
        copyfile(posthdrfile, prehdrfile, 'f');
        
        delete(postimgfile);
        delete(posthdrfile);
        
    end
    
end