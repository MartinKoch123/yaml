function result = parse(s)

arguments
    s (1, 1) string
end

snakeYamlFile = [fileparts(mfilename('fullpath')) '\snakeyaml-1.30.jar'];

if ~ismember(snakeYamlFile, javaclasspath('-dynamic'))
    javaaddpath(snakeYamlFile);
end
import('org.yaml.snakeyaml.*');
try
rootNode = org.yaml.snakeyaml.Yaml().load(s);
catch cause
    MException("parseYaml:Failed", "Failed to parse YAML string.").addCause(cause).throw
end
result = convert(rootNode);

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
    result{i} = convert(list.get(i-1));
end
end