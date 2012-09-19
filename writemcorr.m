function writemcorr(mcorr, p, env, outname)

global CCN;

fh = fopen(outname, 'w');
fprintf(fh, 'contr\t');

stepct = zeros(length(env.allsteps), 1);

for stepidx = 1 : length(env.allsteps)
    
    stepname = env.allsteps{stepidx};
    
    % Check step values
    if ismember(stepname, env.procsteps)
        stepvals = fieldnames(p.proc.(stepname));
    elseif ismember(stepname, env.modelsteps)
        stepvals = fieldnames(p.model.(stepname));
    end
    stepct(stepidx) = length(stepvals);
    if length(stepvals) > 1
        fprintf(fh, '%s\t', stepname);
    end
    
end

fprintf(fh, '\n');

contrnames = fieldnames(CCN.contr.contrs);
for contridx = 1 : length(contrnames)
    
    contrname = contrnames{contridx};
    fprintf(fh, '%s\t', contrname);
    
    for stepidx = 1 : length(stepct)
        
        if stepct(stepidx) > 1
            fprintf(fh, '%f\t', mcorr.(contrname)(stepidx));
        end
        
    end
    
    fprintf(fh, '\n');
    
end

fclose(fh);