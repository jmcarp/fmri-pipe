function permrfx(start, step)

global CCN;
if isempty(CCN)
    batchpar_008;
end

CCN.steps = { 'rfx_b' 'rfxclean_b' };
% CCN.rfx.des = 'basisfx';

p = getpermlist;
env = getpenv(p, CCN);

[optlist optmat] = reclist(1, {}, {}, {}, p, env, CCN);

for optidx = start : step : length(optlist)
    
    % Get options
    opts = optlist{optidx};
    mat = optmat(optidx, :);
    
%     switch mat{12}
%         case 'hrf'
%             CCN.model.basis = 'hrf';
%             CCN.model.derivs = 'none';
%         case 'inf'
%             CCN.model.basis = 'hrf';
%             CCN.model.derivs = 'disp';
%         case 'fir'
%             CCN.model.basis = 'fir';
%             CCN.model.length = 16;
%     end
    
    if strcmp(mat{12}, 'hrf')
        
        CCN.model.basis = 'hrf';
        CCN.model.derivs = 'none';
        
        CCN.rfx.des = '1stt';
        
        % Set model directory
        CCN.model.model_dir = sprintf( ...
            '[root_dir]/subjs/[subject]/perm/model_%s', ...
            opts);

        % Set rfx directory
        CCN.rfx.dir = sprintf( ...
            '[root_dir]/permrfx/%s', ...
            opts);

        % Run batch
        batch8;
        
    elseif strcmp(mat{12}, 'fir')
        
        CCN.model.basis = 'fir';
        CCN.model.length = 16;
        
        %% 
        
        CCN.rfx.des = 'basis_1stt';
        
        modmat = mat;
        modmat{12} = 'firtt';
        modopt = joindelim(modmat, '_');
        
        % Set model directory
        CCN.model.model_dir = sprintf( ...
            '[root_dir]/subjs/[subject]/perm/model_%s', ...
            opts);

        % Set rfx directory
        CCN.rfx.dir = sprintf( ...
            '[root_dir]/permrfx/%s', ...
            modopt);

        % Run batch
        batch8;
        
        %% 
        
        CCN.rfx.des = 'basisfx';
        
        modmat = mat;
        modmat{12} = 'firaov';
        modopt = joindelim(modmat, '_');
        
        % Set model directory
        CCN.model.model_dir = sprintf( ...
            '[root_dir]/subjs/[subject]/perm/model_%s', ...
            opts);

        % Set rfx directory
        CCN.rfx.dir = sprintf( ...
            '[root_dir]/permrfx/%s', ...
            modopt);

        % Run batch
        batch8;
        
    end
    
end
