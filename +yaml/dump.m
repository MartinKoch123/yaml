function result = dump(data, style)
%DUMP Convert data to YAML string
%   STR = YAML.DUMP(DATA) converts DATA to a YAML string STR.
%
%   STR = YAML.DUMP(DATA, STYLE) uses a specific output style.
%   STYLE can be "auto" (default), "block" or "flow".
%
%   The following types are supported for DATA:
%       MATLAB type             | YAML type
%       ------------------------|----------------------
%       1D cell array           | Sequence
%       1D non-scalar array     | Sequence
%       2D/3D cell array        | Nested sequences
%       2D/3D non-scalar array  | Nested sequences
%       struct                  | Mapping
%       scalar single/double    | Floating-point number
%       scalar int8/../int64    | Integer
%       scalar uint8/../uint64  | Integer
%       scalar logical          | Boolean
%       scalar string           | String
%       char vector             | String
%       any 0-by-0 value        | null
%
%   Array conversion can be ambiguous. To ensure consistent conversion
%   behaviour, consider manually converting array data to nested 1D cells
%   before converting it to YAML.
%
%   Example:
%       >> DATA.a = 1
%       >> DATA.b = {"hello", false}
%       >> STR = yaml.dump(DATA)
%
%         "a: 1.0
%         b: [hello, false]
%         "
%
%   See also YAML.DUMPFILE, YAML.LOAD, YAML.LOADFILE

arguments
    data
    style {mustBeMember(style, ["flow", "block", "auto"])} = "auto"
end

initializeSnakeYaml
import org.yaml.snakeyaml.*;

try
    javaData = convert(data);
catch exception
    if string(exception.identifier).startsWith("yaml:dump")
        error(exception.identifier, exception.message);
    end
    exception.rethrow;
end
dumperOptions = DumperOptions();
setFlowStyle(dumperOptions, style);
result = Yaml(dumperOptions).dump(javaData);
result = string(result);

    function result = convert(data)
        if sum(size(data)) == 0 % null
            result = data;
        elseif isempty(data)
            result = java.util.ArrayList();
        elseif iscell(data)
            result = convertCell(data);
        elseif isfloat(data)
            result = data;
        elseif isinteger(data) || islogical(data) || isstruct(data)
            result = convertIntegerOrLogical(data);
        elseif isstring(data) || (ischar(data) && isrow(data))
            result = data;
        elseif ~isscalar(data)
            result = convertArray(data);
        else
            error("yaml:dump:TypeNotSupported", "Data type '%s' is not supported.", class(data))
        end
    end

    function result = convertCell(data)
        data = nest(data);
        result = java.util.ArrayList();
        for i = 1:length(data)
            result.add(convert(data{i}));
        end
    end

    function result = convertArray(data)
        result = convertCell(num2cell(data));
    end

    function result = convertScalar_integer(data, javaType)
        result = java.(javaType)(data);
    end

    function result = convertScalar_uint32_uint64(data)
        hexStr = dec2hex(data);
        result = java.math.BigInteger(hexStr, 16);
    end

    function result = convertScalar_struct(data)
        result = java.util.LinkedHashMap();
        for key = string(fieldnames(data))'
            value = convert(data.(key));
            result.put(key, value);
        end
    end

    function result = convertIntegerOrLogical(data)
        switch class(data)
            case {"uint32", "uint64"};  javaType = "math.BigInteger";   converter = @convertScalar_uint32_uint64;
            case "int64";               javaType = "lang.Long";         converter = @(data) convertScalar_integer(data, javaType);
            case "logical";             javaType = "lang.Boolean";      converter = @(data) convertScalar_integer(data, javaType);
            case "struct";              javaType = "util.LinkedHashMap"; converter = @convertScalar_struct;
            otherwise;                  javaType = "lang.Integer";      converter = @(data) convertScalar_integer(data, javaType);
        end

        % Dump MATLAB scalars (i.e. 2-D arrays with one element) as scalars.
        if isscalar(data)
            result = converter(data);
            return
        end

        % Create Java array.
        if isvector(data)

            % Dump MATLAB vectors (i.e. 2-D arrays where one dimension has size 1) as a sequences.
            size_ = numel(data);
        else

            % Dump MATLAB non-vector, non-scalar arrays as nested sequences.
            size_ = size(data);
        end
        nDims = length(size_);
        result = javaArray("java." + javaType, size_);

        % Loop over elements in N-D array via linear indexing.
        for i = 1 : numel(data)

            % Convert linear index to N-D array subscripts.
            [subscripts{1:nDims}] = ind2sub(size_, i);

            % Add scalar to Java array.
            result(subscripts{:}) = converter(data(i));
        end
    end

    function result = nest(data)
        if isvector(data) || isempty(data)
            result = data;
            return
        end
        n = size(data, 1);
        nDimensions = length(size(data));
        result = cell(1, n);
        if nDimensions == 2
            for i = 1:n
                result{i} = data(i, :);
            end
        elseif nDimensions == 3
            for i = 1:n
                result{i} = squeeze(data(i, :, :));
            end
        else
            error("yaml:dump:HigherDimensionsNotSupported", "Arrays with more than three dimensions are not supported. Use nested cells instead.")
        end
    end

    function setFlowStyle(options, style)
        import org.yaml.snakeyaml.*;
        if style == "auto"
            return
        end
        classes = options.getClass.getClasses;
        classNames = arrayfun(@(c) string(c.getName), classes);
        styleClassIndex = find(classNames.endsWith("$FlowStyle"), 1);
        if isempty(styleClassIndex)
            error("yaml:dump:FlowStyleSelectionFailed", "Unable to select flow style '%s'.", style);
        end
        styleFields = classes(styleClassIndex).getDeclaredFields();
        styleIndex = find(arrayfun(@(f) string(f.getName).lower == style, styleFields));
        if isempty(styleIndex)
            error("yaml:dump:FlowStyleSelectionFailed", "Unable to select flow style '%s'.", style);
        end
        options.setDefaultFlowStyle(styleFields(styleIndex).get([]));
    end

end
