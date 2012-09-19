function env = getpenv(p, CCN)

env = struct();

env.matdir = sprintf('%s/tmpmat', ...
    CCN.root_dir);

env.scriptdir = '/data00/jmcarp/scripts/open';

env.jobdir = sprintf('%s/permjobs', env.scriptdir);
if ~exist(env.jobdir, 'dir')
    mkdir(env.jobdir);
end
env.statdir = sprintf('%s/permstat', CCN.root_dir);
if ~exist(env.statdir, 'dir')
    mkdir(env.statdir);
end

env.procsteps = fieldnames(p.proc);
env.modelsteps = fieldnames(p.model);
env.allsteps = [env.procsteps ; env.modelsteps];

env.procperms = 1;
for stepidx = 1 : length(env.procsteps)
    step = env.procsteps{stepidx};
    env.procperms = env.procperms * ...
        length(fieldnames(p.proc.(step)));
end

env.modelperms = 1;
for stepidx = 1 : length(env.modelsteps)
    step = env.modelsteps{stepidx};
    env.modelperms = env.modelperms * ...
        length(fieldnames(p.model.(step)));
end

env.allperms = env.procperms * env.modelperms;