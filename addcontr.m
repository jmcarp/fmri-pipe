function [optlistxtra optmatxtra contrlist p] = ...
    addcontr(optlist, optmat, p, env)

basisidx = ismember(env.allsteps, 'basis');

optmatxtra = {};
optlistxtra = {};
contrlist = {};

for optidx = 1 : length(optlist)
    
    opts = optmat(optidx, :);
    
    switch opts{basisidx}
        
        case 'hrf'
            
            optmatxtra = [optmatxtra ; opts];
            optlistxtra = [optlistxtra joindelim(opts, '_')];
            contrlist = [contrlist '+'];
            
        case 'fir'
            
            opts{basisidx} = 'firtt';
            optmatxtra = [optmatxtra ; opts];
            optlistxtra = [optlistxtra joindelim(opts, '_')];
            contrlist = [contrlist '+'];
            
            opts{basisidx} = 'firaov';
            optmatxtra = [optmatxtra ; opts];
            optlistxtra = [optlistxtra joindelim(opts, '_')];
            contrlist = [contrlist 'Main effect of basis'];
            
    end
    
end

% firidx = ismember(optmat(:, basisidx), 'fir');
% 
% optlist = [optlist optlist(firidx)];
% optxtra = optmat(firidx, :);
% optxtra(:, basisidx) = repmat({'cxb'}, sum(firidx), 1);
% optmat = [optmat ; optxtra];
% % optmat = [optmat ; optmat(firidx, :)];
% contrlist = [ ...
%     repmat({'Effects of Interest'}, env.allperms, 1)
%     repmat({'Main effect of basis'}, sum(firidx), 1)
%     ];

% Update p
p.model.basis = struct( ...
    'hrf', struct(), ...
    'firtt', struct(), ...
    'firaov', struct() ...
);
% p.model.basis.cxb = struct();