function s = catstruct(varargin)

s = struct();
for sidx = 1 : length(varargin)
    stemp = varargin{sidx};
    if ~isstruct(stemp)
        error('all arguments must be structs');
    end
    fields = fieldnames(stemp);
    for fidx = 1 : length(fields)
        field = fields{fidx};
        s.(field) = stemp.(field);
    end
end