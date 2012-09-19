function batch_permrfx(nmat)

swd = pwd;
cd('/data00/jmcarp/scripts/open');

for matidx = 1 : nmat
    
    cmd = sprintf('nice -n 10 matlab -r "permrfx(%d, %d); exit;" > rfx%d &', ...
        matidx, nmat, matidx);
    disp(cmd);
    system(cmd);
    
end

cd(swd);
