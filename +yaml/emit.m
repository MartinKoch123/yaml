function result = emit(data)

arguments
    data
end

import yaml.initSnakeYaml
initSnakeYaml
import('org.yaml.snakeyaml.DumperOptions');
import('org.yaml.snakeyaml.Yaml');

javaData = convert(data);
options = DumperOptions();
options.setLineBreak(javaMethod('getPlatformLineBreak', 'org.yaml.snakeyaml.DumperOptions$LineBreak'));
result = Yaml(options).dump(javaData);
result = string(result);
end

function result = convert(data)
    if isstruct(data)
        result = convertStruct(data);
    elseif iscell(data)
        result = convertCell(data);
    elseif ~isscalar(data)
        error("emit:ArrayNotSupported", "Non-cell arrays are not supported.")
    elseif isfloat(data)
        result = java.lang.Double(data);
    elseif isinteger(data)
        result = java.lang.Integer(data);
    elseif islogical(data)
        result = java.lang.Boolean(data);
    elseif ischar(data) || isstring(data)
        result = java.lang.String(data);
    else
        error("emit:TypeNotSupported", "Data type '%s' is not supported.", class(data))
    end
end

function result = convertStruct(data)
    result = java.util.LinkedHashMap();
    for key = string(fieldnames(data))'
        value = convert(data.(key));
        result.put(key, value);
    end
end

function result = convertCell(data)
    if ~isvector(data)
        error("emit:NonVectorCellNotSupported", "Non-vector cell arrays are not supported.")
    end
    result = java.util.ArrayList();
    for i = 1:length(data)
        result.add(convert(data{i}));
    end
end
