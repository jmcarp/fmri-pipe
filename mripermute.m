function mripermute

global CCN;
if isempty(CCN)
    batchpar_008;
end

p = getpermlist;
env = getpenv(p, CCN);

% Delete temporary files
cmd = sprintf('rm %s/model*', env.matdir);
system(cmd);

recpermute(1, {}, p, env, CCN);

function recpermute(stepidx, opts, p, env, CCN)

if stepidx <= length(env.procsteps)
    grp = 'proc';
else
    grp = 'model';
end

step = env.allsteps{stepidx};
valnames = fieldnames(p.(grp).(step));

for validx = 1 : length(valnames)
    
    val = valnames{validx};
    opts{stepidx} = val;
    
    parnames = fieldnames(p.(grp).(step).(val));
    
    if strcmp(grp, 'proc')
        
        for paridx = 1 : length(parnames)
            par = parnames{paridx};
            CCN.(step).(par) = p.(grp).(step).(val).(par);
        end
        
        CCN.steps = { sprintf('%s_b', step) };
        batch8(CCN);
        
    elseif strcmp(grp, 'model')
        
        for paridx = 1 : length(parnames)
            par = parnames{paridx};
            CCN.model.(par) = p.(grp).(step).(val).(par);
        end
        
        if stepidx == length(env.allsteps)
            
            CCN.model.model_dir = sprintf( ...
                '[root_dir]/subjs/[subject]/perm/model_%s', ...
                joindelim(opts, '_'));
            CCN.roix.savename = sprintf('%s/roix.mat', ...
                CCN.model.model_dir);
            roifile = expandpath(CCN.roix.savename, false, 1);
            spmffile = sprintf('%s/spmF_0001.img', ...
                expandpath(CCN.model.model_dir, false, 1));
            if true%~exist(roifile, 'file') || ~exist(spmffile, 'file')
%                 CCN.steps = { 'model_b' 'contrast_b' ...
%                     'roixtract_b' 'modclean_b' };
                CCN.steps = { 'model_b' 'contrast_mod_b' ...
                    'modclean_b' };
                apptxt = '';
            else
                CCN.steps = {};
                apptxt = 'skip';
            end
            
            % 
            matname = sprintf('%s/model_%s.mat%s', ...
                env.matdir, joindelim(opts, '_'), apptxt);
            save(matname, 'CCN');
            
            % 
            mname = sprintf('%s/model_%s.m%s', ...
                env.matdir, joindelim(opts, '_'), apptxt);
            fh = fopen(mname, 'w');
            fprintf(fh, 'global CCN;\n');
            fprintf(fh, 'load(''%s'');\n', matname);
            fprintf(fh, 'batch8;\n');
            fclose(fh);
            
        end
        
        mfiles = dir(sprintf('%s/*.m', env.matdir));
        mfiles = {mfiles.name};
        skipfiles = dir(sprintf('%s/*.mskip', env.matdir));
        
        % maxcmd = 10;
        maxcmd = 8;
        
        if stepidx == length(env.allsteps) && ...
                (length(mfiles) + length(skipfiles)) == env.modelperms
            
            cmdct = 1;
            mdirs = {};
            matcmd = {};
            pidcmd = {};
            waicmd = {};
            
            for modidx = 1 : length(mfiles)
                
                mfile = mfiles{modidx};
                [~, mname] = fileparts(mfile);
                logdir = sprintf('%s/permlog', CCN.root_dir);
                if ~ exist(logdir, 'dir')
                    mkdir(logdir);
                end
                logfile = sprintf('%s/%s_%s', ...
                    logdir, mname, CCN.subject);
                mpath = sprintf( ...
                    '[root_dir]/subjs/[subject]/perm/%s', ...
                    mname);
                mdirs{cmdct} = expandpath(mpath, false, 1);
                matcmd{cmdct} = sprintf('nice -n 10 matlab -nodisplay < %s/%s > %s &\n', ...
                    env.matdir, mfile, logfile);
                % matcmd{cmdct} = sprintf('matlab -nodisplay < %s/%s > %s &\n', ...
                %     env.matdir, mfile, logfile);
                pidcmd{cmdct} = sprintf('pid%d=$!\n', modidx);
                waicmd{cmdct} = sprintf('wait $pid%d\n', modidx);
                cmdct = cmdct + 1;
                
                if cmdct > maxcmd || modidx == length(mfiles)
                    
                    outname = sprintf('%s/parcmd/par', CCN.root_dir);
                    outfile = fopen(outname, 'w');
                    for cmdidx = 1 : cmdct - 1
                        fprintf(outfile, matcmd{cmdidx});
                        fprintf(outfile, pidcmd{cmdidx});
                    end
                    for cmdidx = 1 : cmdct - 1
                        fprintf(outfile, waicmd{cmdidx});
                    end
                    fclose(outfile);
                    
                    cmd = sprintf('sh %s', outname);
                    catcmd = sprintf('cat %s', outname);
                    
                    roicheck = false;
                    
                    while ~roicheck
                        system(catcmd);
                        system(cmd);
                        roicheck = modcheck(mdirs);
                    end
                    
                    % Initialize commands
                    cmdct = 1;
                    mdirs = {};
                    matcmd = {};
                    pidcmd = {};
                    waicmd = {};
                    
                end
                
            end
            
            % Delete temporary files
            cmd = sprintf('rm %s/model*', env.matdir);
            system(cmd);
            
        end
        
    end
    
    if stepidx < length(env.allsteps)
        recpermute(stepidx + 1, opts, p, env, CCN);
    end
    
end

function ok = modcheck(mdirs)

ok = true;
for diridx = 1 : length(mdirs)
    mdir = mdirs{diridx};
%     roifile = sprintf('%s/roix.mat', mdir);
%     spmffile = sprintf('%s/spmF_0002.img', mdir);
    detfile = sprintf('%s/mdetail.mat', mdir);
%     if ~exist(spmffile, 'file')
    if ~exist(detfile, 'file')
        ok = false;
        break;
    end
%     if ~exist(roifile, 'file') || ...
%             ~exist(spmffile, 'file')
%         ok = false;
%         break;
%     end
end
