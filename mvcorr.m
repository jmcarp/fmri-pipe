function [mvc vvc] = mvcorr(level)

global CCN;
if isempty(CCN)
    batchpar_008;
end

p = getpermlist;
env = getpenv(p, CCN);

contrnames = fieldnames(CCN.contr.contrs);

statdir = sprintf('%s/permstat', ...
    CCN.root_dir);

if strcmp(level, 'l1')
    level = 'l1/grp';
end

for contridx = 1 : length(contrnames)
    
    % Get contrast name
    contrname = contrnames{contridx};
    
    meanname = sprintf('%s/%s/%s/permmean.img', ...
        statdir, contrname, level);
    meanvol = spm_vol(meanname);
    meanimg = spm_read_vols(meanvol);
    incvox = ~isnan(meanimg);
    
    rngname = sprintf('%s/%s/%s/permrng.img', ...
        statdir, contrname, level);
    rngvol = spm_vol(rngname);
    rngimg = spm_read_vols(rngvol);
    
    mvc(contridx, 1) = corr( ...
        meanimg(incvox), rngimg(incvox));
    
    % 
    mdidx = 2;
    stepct = 1;
    for stepidx = 1 : length(env.allsteps)
        
        step = env.allsteps{stepidx};
        
        mdname = sprintf('%s/%s/%s/md_%s.img', ...
            statdir, contrname, level, step);
        if ~exist(mdname, 'file')
            continue
        end
        mdvol = spm_vol(mdname);
        mdimg = spm_read_vols(mdvol);
        
        mvc(contridx, mdidx) = corr( ...
            meanimg(incvox), mdimg(incvox));
        mdidx = mdidx + 1;
        
        stepct2 = 1;
        for stepidx2 = 1 : length(env.allsteps)
            
            step2 = env.allsteps{stepidx2};
            
            mdname2 = sprintf('%s/%s/%s/md_%s.img', ...
                statdir, contrname, level, step2);
            if ~exist(mdname2, 'file')
                continue
            end
            mdvol2 = spm_vol(mdname2);
            mdimg2 = spm_read_vols(mdvol2);
            
            if stepidx == stepidx2
                vvc(contridx, stepct, stepct2) = nan;
            else
                vvc(contridx, stepct, stepct2) = ...
                    corr(mdimg(incvox), mdimg2(incvox));
            end
            
            stepct2 = stepct2 + 1;
            
        end
        
        stepct = stepct + 1;
        
    end
    
end