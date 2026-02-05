function result = load(s, options)
% Parse a YAML string into MATLAB data types.
%
%   :code:`result = yaml.load(s)` parses the YAML document contained in the string
%   :code:`s` and converts it into MATLAB data types.
%
%   :code:`result = yaml.load(s, options)` allows control over the conversion
%   behavior using name-value options.
%
%   Parameters
%   ----------
%   s : string (1x1)
%     YAML document to be parsed, provided as a string.
%
%   options.ConvertToArray : logical, default = false
%     If true, YAML sequences are converted to non-cell MATLAB arrays whenever
%     possible. For example, :code:`result = yaml.load(s, 'ConvertToArray', true)`
%     or :code:`result = yaml.load(s, ConvertToArray=true)`.
%
%   Returns
%   -------
%   result : struct, array, cell or scalar
%     MATLAB representation of the parsed YAML document, with types inferred
%     from the YAML content.
%
%   Notes
%   -----
%   
%   The following table summarizes the mapping from YAML types to MATLAB
%   types:
%
%   +----------------------------+------------------------------------------+
%   | YAML type                  | MATLAB type                              |
%   +============================+==========================================+
%   | Sequence                   | cell (or array if ConvertToArray = true) |
%   +----------------------------+------------------------------------------+
%   | Mapping                    | struct                                   |
%   +----------------------------+------------------------------------------+
%   | Floating-point number      | double                                   |
%   +----------------------------+------------------------------------------+
%   | Integer                    | double                                   |
%   +----------------------------+------------------------------------------+
%   | Boolean                    | logical                                  |
%   +----------------------------+------------------------------------------+
%   | String                     | string                                   |
%   +----------------------------+------------------------------------------+
%   | Date (yyyy-mm-ddTHH:MM:SS) | datetime                                 |
%   +----------------------------+------------------------------------------+
%   | Date (yyyy-mm-dd)          | datetime                                 |
%   +----------------------------+------------------------------------------+
%   | null                       | 0-by-0 double                            |
%   +----------------------------+------------------------------------------+
%
%   Examples
%   --------
%   >>> str = "{a: 1, b: [text, false]}";
%   >>> result = yaml.load(str)
%     struct with fields:
%       a: 1
%       b: {["text"]  [0]}
%
%   See Also
%   --------
%   yaml.loadFile
%   yaml.dump
%   yaml.dumpFile
 
arguments
    s (1, 1) string
    options.ConvertToArray (1, 1) logical = false
end

initializeSnakeYaml
import org.yaml.snakeyaml.*;
try
    rootNode = Yaml().load(s);
catch cause
    MException("yaml:load:Failed", "Failed to load YAML string.").addCause(cause).throw
end

try
    result = convert(rootNode, options.ConvertToArray);
catch exc
    if startsWith(exc.identifier, "yaml:load:")
        error(exc.identifier, exc.message);
    end
    exc.rethrow;
end

end

function result = convert(node, convertToArray)
    switch class(node)
        case "double" % null is loaded as 0-by-0
            result = node;
        case "char"
            result = string(node);
        case "logical"
            result = logical(node);
        case "java.util.LinkedHashMap"
            result = convertMap(node, convertToArray);
        case "java.util.ArrayList"
            result = convertList(node, convertToArray);
        case "java.util.Date"
            long = node.getTime;
            result = datetime(long, "ConvertFrom", "epochtime", "TicksPerSecond", 1000, "TimeZone", "UTC", "Format", "dd-MMM-uuuu HH:mm:ss.SSS z");
        case "java.math.BigInteger"
            error("yaml:load:IntOutOfRange", "Integer '%s' is out of the supported range.", node.toString())
        otherwise
            error("yaml:load:TypeNotSupported", "Data type '%s' is not supported.", class(node))
    end
end

function result = convertMap(map, convertToArray)
    result = struct();

    keys = string(map.keySet().toArray())';
    fieldNames = matlab.lang.makeValidName(keys);
    fieldNames = matlab.lang.makeUniqueStrings(fieldNames);

    for i = 1:map.size()
        value = map.get(java.lang.String(keys(i)));
        result.(fieldNames(i)) = convert(value, convertToArray);
    end
end

function result = convertList(list, convertToArray)

    % Convert Java list to cell array.
    result = cell(list.size(), 1);
    for i = 1:list.size()
        result{i} = convert(list.get(i - 1), convertToArray);
    end

    if ~convertToArray
        return; end

    % Convert to non-cell array if possible
    if isempty(result)
        result = zeros(1, 0);
        return
    elseif ~elementsHaveEqualType(result) || ~elementsAreAllNonNull(result)
        return
    elseif isstruct(result{1}) && ~structsAreCompatible(result)
        return
    elseif elementsHaveEqualSize(result)
        numDims = effectiveSize(result{1});

        % Since we are working our way "inside-out", i.e. from the last
        % dimension to the first dimension, we need to concatenate
        % along a "new first dimension" before the current first
        % dimension. This is done by first concatenating along a new
        % dimension behind the last dimension ...
        result = cat(numDims + 1, result{:});

        % ... and then swapping the new last dimension with the
        % first dimension.
        if numDims > 0
            result = permute(result, [numDims+1, 1 : numDims]);
        end
    end
end

function result = elementsAreAllNonNull(cell_)
    result = all(cellfun(@(x) max(size(x)) > 0, cell_));
end

function result = elementsHaveEqualType(cell_)
    type1 = class(cell_{1});
    result = all( ...
        cellfun(@(x) isequal(class(x), type1), cell_) ...
    );
end

function result = elementsHaveEqualSize(cell_)
    size1 = size(cell_{1});
    result = all( ...
        cellfun(@(x) isequal(size(x), size1), cell_) ...
    );
end

function result = structsAreCompatible(cell_)
    fields = sort(fieldnames(cell_{1}));
    result = all(cellfun(@(s) isequal(sort(fieldnames(s)), fields), cell_));
end
