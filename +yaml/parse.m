function result = parse(s)
%PARSE Parse YAML string
%   Parse a string in YAML format and convert it to appropriate
%   data types.

arguments
    s (1, 1) string
end

yaml.initSnakeYaml
import org.yaml.snakeyaml.Yaml;
try
    rootNode = Yaml().load(s);
catch cause
    MException("parseYaml:Failed", "Failed to parse YAML string.").addCause(cause).throw
end
try
result = convert(rootNode);
catch exception
    if string(exception.identifier).startsWith("parseYaml") 
        error(exception.identifier, exception.message);
    end
    exception.rethrow;
end

end

function result = convert(node)
    switch class(node)
        case "double"
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
            error("parseYaml:TypeNotSupported", "Data type '%s' is not supported.", class(node))
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