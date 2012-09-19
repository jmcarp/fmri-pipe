function rfx_b

global CCN;

switch CCN.rfx.des
    
    % One-sample t-test
    case '1stt'
        
        if strcmp(CCN.rfx.mtype, 'model')
            contrnames = fieldnames(CCN.contr.contrs);
        elseif strcmp(CCN.rfx.mtype, 'ppi')
            contrnames = fieldnames(CCN.ppicontr.contrs);
        end
        
        for contridx = 1 : length(contrnames)
            
            clear matlabbatch;
            contrname = contrnames{contridx};
            
            % Get model directory
            rfxdir = sprintf('%s/%s', expandpath(CCN.rfx.dir, false, 1), contrname);
            if ~exist(rfxdir, 'dir')
                mkdir(rfxdir);
            end
            
            
            
            matlabbatch{1}.spm.stats.factorial_design.dir = ...
                {rfxdir};
            
            % Set masking
            if isfield(CCN.rfx, 'mask')
                matlabbatch{1}.spm.stats.factorial_design.masking.em = ...
                    {CCN.rfx.mask};
            end
            
            % Get scans
            for subjidx = 1 : length(CCN.subjs)
                CCN.subject = CCN.subjs{subjidx};
                spmdir = expandpath(CCN.model.model_dir, false, 1);
                if strcmp(CCN.rfx.mtype, 'model')
                    mdir = spmdir;
                elseif strcmp(CCN.rfx.mtype, 'ppi')
                    mdir = sprintf('%s/%s', spmdir, CCN.ppi.name);
                end
                matlabbatch{1}.spm.stats.factorial_design.des.t1.scans{subjidx} = ...
                    sprintf('%s/con_%04d.img', mdir, contridx + 1);
            end
            
            % Set up estimation
            spmmat = sprintf('%s/SPM.mat', rfxdir);
            matlabbatch{2}.spm.stats.fmri_est.spmmat = ...
                {spmmat};
            
            % Set up contrasts
            matlabbatch{3}.spm.stats.con.spmmat = {spmmat};
            matlabbatch{3}.spm.stats.con.delete = 1;
            
            % +ve
            matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = ...
                sprintf('+ %s', contrname);
            matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = ...
                [1];
            
            % -ve
            matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = ...
                sprintf('- %s', contrname);
            matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = ...
                [-1];
            
            % F-con
            matlabbatch{3}.spm.stats.con.consess{3}.fcon.name = ...
                contrname;
            matlabbatch{3}.spm.stats.con.consess{3}.fcon.convec = ...
                {1};
            
            % Run job
            spm_jobman('run', matlabbatch);
            
%             catname = spmcat(spmmat, 1, 2);
%             tempname = CCN.norm.hrtemp;
%             spm_reslice({tempname catname}, ...
%                 struct('mean', 0, 'which', 1));
        
        end
        
    % One-sample t-test on basis contrasts
    case 'basis_1stt'
        
        if strcmp(CCN.rfx.mtype, 'model')
            contrnames = fieldnames(CCN.contr.contrs);
        elseif strcmp(CCN.rfx.mtype, 'ppi')
            contrnames = fieldnames(CCN.ppicontr.contrs);
        end
        
        basistypes = fieldnames(CCN.contr.basis);
        
        for contridx = 1 : length(contrnames)
            
            contrname = contrnames{contridx};
            
            for btypeidx = 1 : length(basistypes)
                
                btype = basistypes{btypeidx};
                
                clear matlabbatch;
                
                % Get model directory
                rfxdir = sprintf('%s/%s', ...
                    expandpath(CCN.rfx.dir, false, 1), ...
                    contrname);
%                 rfxdir = sprintf('%s/%s_basis_%s', ...
%                     expandpath(CCN.rfx.dir, false, 1), ...
%                     contrname, btype);
                if ~exist(rfxdir, 'dir')
                    mkdir(rfxdir);
                end
                
                % Set model directory
                matlabbatch{1}.spm.stats.factorial_design.dir = ...
                    {rfxdir};
                
                % Set masking
                if isfield(CCN.rfx, 'mask')
                    matlabbatch{1}.spm.stats.factorial_design.masking.em = ...
                        {CCN.rfx.mask};
                end
                
                % Get scans
                for subjidx = 1 : length(CCN.subjs)
                    
                    CCN.subject = CCN.subjs{subjidx};
                    spmdir = expandpath(CCN.model.model_dir, false, 1);
                    if strcmp(CCN.rfx.mtype, 'model')
                        mdir = spmdir;
                    elseif strcmp(CCN.rfx.mtype, 'ppi')
                        mdir = sprintf('%s/%s', spmdir, CCN.ppi.name);
                    end
                    
                    % Load model details
                    detmat = sprintf('%s/mdetail.mat', spmdir);
                    load(detmat);

                    % Get contrast-basis index
                    cbname = sprintf('%s_basis%s', contrname, btype);
                    cbidx = find(ismember(mdetail.cnames, cbname));
                
                    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans{subjidx} = ...
                        sprintf('%s/con_%04d.img', mdir, cbidx);
                    
                end
            
                % Set up estimation
                spmmat = sprintf('%s/SPM.mat', rfxdir);
                matlabbatch{2}.spm.stats.fmri_est.spmmat = ...
                    {spmmat};

                % Set up contrasts
                matlabbatch{3}.spm.stats.con.spmmat = {spmmat};
                matlabbatch{3}.spm.stats.con.delete = 1;

                % +ve
                matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = ...
                    sprintf('+ %s', contrname);
                matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = ...
                    [1];

                % -ve
                matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = ...
                    sprintf('- %s', contrname);
                matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = ...
                    [-1];
                
                % F-con
                matlabbatch{3}.spm.stats.con.consess{3}.fcon.name = ...
                    contrname;
                matlabbatch{3}.spm.stats.con.consess{3}.fcon.convec = ...
                    {1};
                
                % Run job
                spm_jobman('run', matlabbatch);
                
            end
            
        end
        
    case '2stt'
        
        contrnames = fieldnames(CCN.contr.contrs);
        
        for contridx = 1 : length(contrnames)
            
            clear matlabbatch;
            contrname = contrnames{contridx};
            
            % Get model directory
            rfxdir = sprintf('%s/%s', expandpath(CCN.rfx.dir, false, 1), contrname);
            if ~exist(rfxdir, 'dir')
                mkdir(rfxdir);
            end
            matlabbatch{1}.spm.stats.factorial_design.dir = ...
                {rfxdir};
            
            % Get scans
            group1 = CCN.rfx.groupnames{1};
            matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = ...
                cell(length(CCN.rfx.groups.(group1)), 1);
            for subjidx = 1 : length(CCN.rfx.groups.(group1))
                CCN.subject = CCN.rfx.groups.(group1){subjidx};
                matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1{subjidx} = ...
                    sprintf('%s/con_%04d.img', ...
                    expandpath(CCN.model.model_dir, false, 1), contridx + 1);
            end
            
            group2 = CCN.rfx.groupnames{2};
            matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = ...
                cell(length(CCN.rfx.groups.(group2)), 1);
            for subjidx = 1 : length(CCN.rfx.groups.(group2))
                CCN.subject = CCN.rfx.groups.(group2){subjidx};
                matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2{subjidx} = ...
                    sprintf('%s/con_%04d.img', ...
                    expandpath(CCN.model.model_dir, false, 1), contridx + 1);
            end
            
            % Set up estimation
            spmmat = sprintf('%s/SPM.mat', rfxdir);
            matlabbatch{2}.spm.stats.fmri_est.spmmat = ...
                {spmmat};
            
            % Set up contrasts
            matlabbatch{3}.spm.stats.con.spmmat = {spmmat};
            matlabbatch{3}.spm.stats.con.delete = 1;
            
            % + all
            matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = ...
                sprintf('+ %s %s', group1, group2);
            matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = ...
                [1 1];
            
            % - all
            matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = ...
                sprintf('- %s %s', group1, group2);
            matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = ...
                [-1 -1];
            
            % + group1
            matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = ...
                sprintf('+ %s', group1);
            matlabbatch{3}.spm.stats.con.consess{3}.tcon.convec = ...
                [1 0];
            
            % - group1
            matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = ...
                sprintf('- %s', group1);
            matlabbatch{3}.spm.stats.con.consess{4}.tcon.convec = ...
                [-1 0];
            
            % + group2
            matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = ...
                sprintf('+ %s', group2);
            matlabbatch{3}.spm.stats.con.consess{5}.tcon.convec = ...
                [0 1];
            
            % - group2
            matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = ...
                sprintf('- %s', group2);
            matlabbatch{3}.spm.stats.con.consess{6}.tcon.convec = ...
                [0 -1];
            
            % group1 - group2
            matlabbatch{3}.spm.stats.con.consess{7}.tcon.name = ...
                sprintf('%s - %s', group1, group2);
            matlabbatch{3}.spm.stats.con.consess{7}.tcon.convec = ...
                [1 -1];
            
            % group2 - group1
            matlabbatch{3}.spm.stats.con.consess{8}.tcon.name = ...
                sprintf('%s - %s', group2, group1);
            matlabbatch{3}.spm.stats.con.consess{8}.tcon.convec = ...
                [-1 1];
            
            % Run job
            spm_jobman('run', matlabbatch);
            
        end
        
    case 'aov1'
        
        contrnames = fieldnames(CCN.contr.contrs);
        
        for contridx = 1 : length(contrnames)
            
            clear matlabbatch;
            contrname = contrnames{contridx};
            
            % Get model directory
            rfxdir = sprintf('%s/%s', expandpath(CCN.rfx.dir, false, 1), contrname);
            if ~exist(rfxdir, 'dir')
                mkdir(rfxdir);
            end
            matlabbatch{1}.spm.stats.factorial_design.dir = ...
                {rfxdir};
            
            for cellidx = 1 : length(CCN.rfx.groupnames)
                
                % Get scans
                groupname = CCN.rfx.groupnames{cellidx};
                for subjidx = 1 : length(CCN.rfx.groups.(groupname))
                    CCN.subject = CCN.rfx.groups.(groupname){subjidx};
                    matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(cellidx).scans{subjidx} = ...
                        sprintf('%s/con_%04d.img', ...
                        expandpath(CCN.model.model_dir, false, 1), contridx);
                end
                
            end
            
            spm_jobman('run', matlabbatch);
            
        end
        
    case 'mreg'
        
        if strcmp(CCN.rfx.mtype, 'model')
            contrnames = fieldnames(CCN.contr.contrs);
        elseif strcmp(CCN.rfx.mtype, 'ppi')
            contrnames = fieldnames(CCN.ppicontr.contrs);
        end
        
        for contridx = 1 : length(contrnames)
            
            clear matlabbatch;
            contrname = contrnames{contridx};
            
            % Get model directory
            rfxdir = sprintf('%s/%s', expandpath(CCN.rfx.dir, false, 1), contrname);
            if ~exist(rfxdir, 'dir')
                mkdir(rfxdir);
            end
            matlabbatch{1}.spm.stats.factorial_design.dir = ...
                {rfxdir};
            
            % Get scans
            for subjidx = 1 : length(CCN.subjs)
                CCN.subject = CCN.subjs{subjidx};
                spmdir = expandpath(CCN.model.model_dir, false, 1);
                if strcmp(CCN.rfx.mtype, 'model')
                    mdir = spmdir;
                elseif strcmp(CCN.rfx.mtype, 'ppi')
                    mdir = sprintf('%s/%s', spmdir, CCN.ppi.name);
                end
                matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans{subjidx} = ...
                    sprintf('%s/con_%04d.img', mdir, contridx + 1);
            end
            
            % Get regressors
            regnames = fieldnames(CCN.rfx.mreg);
            for regidx = 1 : length(regnames)
                regname = regnames{regidx};
                regval = CCN.rfx.mreg.(regname);
                matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(regidx).cname = ...
                    regname;
                matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov(regidx).c = ...
                    regval;
            end
            
            % Set up estimation
            spmmat = sprintf('%s/SPM.mat', rfxdir);
            matlabbatch{2}.spm.stats.fmri_est.spmmat = ...
                {spmmat};
            
            % Set up contrasts
            matlabbatch{3}.spm.stats.con.spmmat = {spmmat};
            matlabbatch{3}.spm.stats.con.delete = 1;
            
            conct = 1;
            regnamesx = [regnames' 'intercept'];
            basecon = zeros(length(regnamesx), 1);
            for regidx = 1 : length(regnamesx)
                
                regname = regnamesx{regidx};
                
                % +ve
                convec = basecon;
                convec(regidx) = 1;
                matlabbatch{3}.spm.stats.con.consess{conct}.tcon.name = ...
                    sprintf('+ %s', regname);
                matlabbatch{3}.spm.stats.con.consess{conct}.tcon.convec = ...
                    convec;
                conct = conct + 1;
                
                % -ve
                convec = basecon;
                convec(regidx) = -1;
                matlabbatch{3}.spm.stats.con.consess{conct}.tcon.name = ...
                    sprintf('- %s', regname);
                matlabbatch{3}.spm.stats.con.consess{conct}.tcon.convec = ...
                    convec;
                conct = conct + 1;
                
            end
            
            spm_jobman('run', matlabbatch);
            
        end
        
    case 'rmaov1'
        
        clear matlabbatch;
        
        % Get model directory
        rfxdir = sprintf('%s', expandpath(CCN.rfx.dir, false, 1));
        if ~exist(rfxdir, 'dir')
            mkdir(rfxdir);
        end
        matlabbatch{1}.spm.stats.factorial_design.dir = ...
            {rfxdir};
        
        contrnames = fieldnames(CCN.contr.contrs);
        
        matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'factor1';
        matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = ...
            length(CCN.rfx.rmcontrs);
        matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 1;
        
        for rmcontridx = 1 : length(CCN.rfx.rmcontrs)
            
            matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(rmcontridx).levels = ...
                rmcontridx;
            rmcontr = CCN.rfx.rmcontrs{rmcontridx};
            conidx = find(ismember(contrnames, rmcontr));
            
            for subjidx = 1 : length(CCN.subjs)
                
                subj = CCN.subjs{subjidx};
                CCN.subject = subj;
                
                spmdir = expandpath(CCN.model.model_dir, false, 1);
                matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(rmcontridx).scans{subjidx} = ...
                    sprintf('%s/con_%04d.img', spmdir, conidx);
                
            end
            
        end
        
        % Set up estimation
        spmmat = sprintf('%s/SPM.mat', rfxdir);
        matlabbatch{2}.spm.stats.fmri_est.spmmat = ...
            {spmmat};
        
        spm_jobman('run', matlabbatch);
        
    case 'basisfx'
        
        contrnames = fieldnames(CCN.contr.contrs);
        
        for contridx = 1 : length(contrnames)
            
            clear matlabbatch;
            contrname = contrnames{contridx};
            
            % Get model directory
            rfxdir = sprintf('%s/%s', expandpath(CCN.rfx.dir, false, 1), contrname);
            if ~exist(rfxdir, 'dir')
                mkdir(rfxdir);
            elseif CCN.rfx.overwrite
                rmdir(rfxdir, 's');
                mkdir(rfxdir);
            end
            matlabbatch{1}.spm.stats.factorial_design.dir = ...
                {rfxdir};
            
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

            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'basis';
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = nbasis;
            matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 1;
            
            for basisidx = 1 : nbasis
                
                matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(basisidx).levels = ...
                    [basisidx];
                
            end
            
            % Set masking
            if isfield(CCN.rfx, 'mask')
                matlabbatch{1}.spm.stats.factorial_design.masking.em = ...
                    {CCN.rfx.mask};
            end
            
            % Get scans
            for subjidx = 1 : length(CCN.subjs)
                
                CCN.subject = CCN.subjs{subjidx};
                spmdir = expandpath(CCN.model.model_dir, false, 1);
                if strcmp(CCN.rfx.mtype, 'model')
                    mdir = spmdir;
                elseif strcmp(CCN.rfx.mtype, 'ppi')
                    mdir = sprintf('%s/%s', spmdir, CCN.ppi.name);
                end
%                 spmmat = sprintf('%s/SPM.mat', mdir);
%                 load(spmmat);
%                 connames = {SPM.xCon.name};
                detmat = sprintf('%s/mdetail.mat', mdir);
                load(detmat);
                connames = mdetail.cnames;
                
                for basisidx = 1 : nbasis
                    
                    conname = sprintf('%s_basis%d', contrname, basisidx);
                    conidx = find(ismember(connames, conname), 1);
                    matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(basisidx).scans{subjidx} = ...
                        sprintf('%s/con_%04d.img', spmdir, conidx);
                    
                end
                
            end
            
            % Set up estimation
            spmmat = sprintf('%s/SPM.mat', rfxdir);
            matlabbatch{2}.spm.stats.fmri_est.spmmat = ...
                {spmmat};
            
            % Set up contrasts
            matlabbatch{3}.spm.stats.con.spmmat = {spmmat};
            matlabbatch{3}.spm.stats.con.delete = 0;
            
            matlabbatch{3}.spm.stats.con.consess{1}.fcon.name = ...
                'Effects of Interest';
            matlabbatch{3}.spm.stats.con.consess{1}.fcon.convec = ...
                {eye(nbasis)};
            
%             for basisidx = 1 : nbasis
%                 cvec = zeros(1, nbasis);
%                 cvec(basisidx) = 1;
%                 matlabbatch{3}.spm.stats.con.consess{basisidx + 1}.tcon.name = ...
%                     sprintf('basis%d', basisidx);
%                 matlabbatch{3}.spm.stats.con.consess{basisidx + 1}.tcon.convec = ...
%                     cvec;
%             end
            
            % Run job
            spm_jobman('run', matlabbatch);
            
        end
        
    otherwise
        
        error('rfx design %s not implemented', CCN.rfx.des);
        
end