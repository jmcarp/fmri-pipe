function writecon(con, outname)

global CCN;
if isempty(CCN)
    batchpar_008;
end

p = getpermlist;
env = getpenv(p, CCN);

[optlist optmat] = reclist(1, {}, {}, {}, p, env, CCN);
% [optlist optmat contrlist p] = addcontr(optlist, optmat, p, env);

contrs = fieldnames(CCN.contr.contrs);

fh = fopen(outname, 'w');

rois = fieldnames(con(1));
fields = { 'con' 'stat' 'pval' 'z1t' 'z2t' };

% 
maxlen = 0;
for optidx = 1 : length(optlist)
    maxlen = max(maxlen, size(con.(rois{1}).tc{optidx}, 1));
end

%
tcfields = cell(1, maxlen);
for tcidx = 1 : maxlen
    tcfields{tcidx} = sprintf('tc%02d', tcidx);
end

labfields = [fields tcfields];

lab = [ ...
    'contr' ...
    fieldnames(p.proc)' ...
    fieldnames(p.model)' ...
    ];
for roiidx = 1 : length(rois)
    for fieldidx = 1 : length(labfields)
        lab = [lab sprintf('%s_%s', ...
            rois{roiidx}, labfields{fieldidx})];
    end
end

fprintf(fh, joindelim(lab, '\t'));
fprintf(fh, '\n');

for contridx = 1 : length(contrs)
    
    contr = contrs{contridx};
    
    for optidx = 1 : size(optmat, 1)

        vals = [ ...
            contr ...
            optmat(optidx, :) ...
            ];
        for roiidx = 1 : length(rois)
            roi = rois{roiidx};
            for fieldidx = 1 : length(fields)
                field = fields{fieldidx};
                vals = [vals num2str(con.(roi).(field)(optidx, contridx))];
            end
            tc = con.(roi).tc{optidx}(:, roiidx);
            for tcidx = 1 : maxlen
                if length(tc) >= tcidx
                    tcval = tc(tcidx);
                else
                    tcval = '.';
                end
                vals = [vals num2str(tcval)];
            end
        end
        fprintf(fh, joindelim(vals, '\t'));
        fprintf(fh, '\n');

    end

end

fclose(fh);