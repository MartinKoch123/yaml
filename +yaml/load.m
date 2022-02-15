function result = load(s)
%LOAD Parse YAML string
%   Parse a string in YAML format and convert it to appropriate
%   data types.

arguments
    s {mustBeNonzeroLengthText}
end

initSnakeYaml
import org.yaml.snakeyaml.*;
try
    rootNode = Yaml().load(s);
catch cause
    MException("load:Failed", "Failed to load YAML string.").addCause(cause).throw
end

try
    result = convert(rootNode);
catch exc
    if exc.identifier == "load:TypeNotSupported"
        error(exc.identifier, exc.message);
    end
    exc.rethrow;
end

end

function result = convert(node)
    switch class(node)
        case "double"
            if isempty(node)
                error("load:TypeNotSupported", "'null' is not supported.")
            end
            result = node;
        case "char"
            result = string(node);
        case "logical"
            result = logical(node);
        case "java.util.LinkedHashMap"
            result = convertMap(node);
        case "java.util.ArrayList"
            result = convertList(node);
        otherwise
            error("load:TypeNotSupported", "Data type '%s' is not supported.", class(node))
    end
end

function result = convertMap(map)
    result = struct();
    
    keys = string(map.keySet().toArray())';
    fieldNames = matlab.lang.makeValidName(keys);
    fieldNames = matlab.lang.makeUniqueStrings(fieldNames);
    
    for i = 1:map.size()
        value = map.get(java.lang.String(keys(i)));
        result.(fieldNames(i)) = convert(value);
    end
end

function result = convertList(list)
    result = cell(1, list.size());
    for i = 1:list.size()
        result{i} = convert(list.get(i - 1));
    end
end

function initSnakeYaml
    snakeYamlFile = fullfile(fileparts(mfilename('fullpath')), 'snakeyaml', 'snakeyaml-1.30.jar');
    if ~ismember(snakeYamlFile, javaclasspath('-dynamic'))
        javaaddpath(snakeYamlFile);
    end
end