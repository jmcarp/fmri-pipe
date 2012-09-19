function makespecs_008

global CCN;

nruns = 3;
nconds = 3;

condnames = { 'go' 'sstop' 'fstop' };

for subjidx = 1 : length(CCN.subjs)
    
    subj = CCN.subjs{subjidx};
    spec = {};
    
    for runidx = 1 : nruns
        
        for condidx = 1 : nconds
            
            condfile = sprintf('%s/subjs/%s/behav/task002_run00%d/cond00%d.txt', ...
                CCN.root_dir, subj, runidx, condidx);
            condhand = fopen(condfile, 'r');
            conddata = textscan(condhand, '%f %f %f', ...
                'delimiter', '\t');
            fclose(condhand);
            
            fprintf('Subject %s, run %d, cond %d: %d trials\n', ...
                subj, runidx, condidx, length(conddata{1}));
            
            spec{runidx}{condidx}.name = condnames{condidx};
            spec{runidx}{condidx}.onset = conddata{1};
            spec{runidx}{condidx}.dur = conddata{2};
            
        end
        
    end
    
    savename = sprintf('%s/spec_%s.mat', ...
        CCN.specdir, subj);
    save(savename, 'spec');
    
end