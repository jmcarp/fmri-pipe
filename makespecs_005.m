function makespecs

global CCN;

nruns = 3;

for subjidx = 1 : length(CCN.subjs)
    
    subj = CCN.subjs{subjidx};
    spec = {};
    
    for runidx = 1 : nruns
        
        behavfile = sprintf('%s/subjs/%s/behav/task001_run00%d/behavdata.txt', ...
            CCN.root_dir, subj, runidx);
        behavhand = fopen(behavfile, 'r');
        behavdata = textscan(behavhand, '%f %f %f %f %f %f %f', ...
            'delimiter', '\t', 'headerlines', 1);
        fclose(behavhand);
        
        incidx = behavdata{6} ~= -1;
        excidx = behavdata{6} == -1;
        
        spec{runidx}{1}.name = 'task';
        spec{runidx}{1}.onset = behavdata{1}(incidx);
        spec{runidx}{1}.dur = 3;
        
        spec{runidx}{1}.param(1) = struct( ...
            'name', 'gain', ...
            'poly', 1, ...
            'param', behavdata{2}(incidx) ...
            );
        
        spec{runidx}{1}.param(2) = struct( ...
            'name', 'loss', ...
            'poly', 1, ...
            'param', behavdata{3}(incidx) ...
            );
        
        if any(excidx)
            spec{runidx}{2}.name = 'other';
            spec{runidx}{2}.onset = behavdata{1}(excidx);
            spec{runidx}{2}.dur = 3;
        end
        
    end
    
    savename = sprintf('%s/spec_%s.mat', ...
        CCN.specdir, subj);
    save(savename, 'spec');
    
end