function [optlist optmat] = reclist(stepidx, opts, optlist, optmat, p, env, CCN)

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
    
    if stepidx == length(env.allsteps)
        optlist = [optlist joindelim(opts, '_')];
        optmat = [optmat ; opts];
    end
    
    if stepidx < length(env.allsteps)
        [optlist optmat] = reclist(stepidx + 1, opts, optlist, optmat, p, env, CCN);
    end
    
end