function xidx = getxconidx(SPM, contrname, contrtype)

% Get contrast name
if strcmp(contrtype, '+')
    cname = contrname;
else
    cname = 'Main effect of basis';
end

% Get xCon index
xnames = {SPM.xCon.name};
xidx = find(ismember(xnames, cname), 1);