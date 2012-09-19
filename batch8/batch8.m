function batch8(varargin)

global CCN;

if nargin > 0
    CCN = varargin{1};
end

if isempty(findobj('-regexp', 'name', 'SPM8.*?Graphics'))
    spm fmri;
end

CCN.groupsteps = { 'roixtract_b' 'rfx_b' };

for stepidx = 1 : length(CCN.steps)
    
    % Update step
    CCN.step = CCN.steps{stepidx};
    
    % Update file pattern
    if isfield(CCN.file_pattern, CCN.step)
        CCN.curr_pattern = CCN.file_pattern.(CCN.step);
    else
        CCN.curr_pattern = CCN.file_pattern.default;
    end
    
    if ismember(CCN.step, CCN.groupsteps)
        
        % Run step
        feval(CCN.step);
        
    else
        
        for subjidx = 1 : length(CCN.subjs)

            % Update subject
            CCN.subject = CCN.subjs{subjidx};
            CCN.csubject = regexprep(CCN.subject, '[\/]', '');

            % Run step
            feval(CCN.step);

        end
        
    end
    
end
