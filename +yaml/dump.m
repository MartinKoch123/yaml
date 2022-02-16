function result = dump(data, options)
%DUMP Convert data to YAML string

arguments
    data
    options.Style {mustBeMember(options.Style, ["flow", "block", "auto"])} = "auto"
end

initSnakeYaml
import org.yaml.snakeyaml.*;

try
    javaData = convert(data);
catch exception
    if string(exception.identifier).startsWith("dump") 
        error(exception.identifier, exception.message);
    end
    exception.rethrow;
end
dumperOptions = getDumperOptions(options.Style);
result = Yaml(dumperOptions).dump(javaData);
result = string(result);

end

function result = convert(data)
    if iscell(data)
        result = convertCell(data);
    elseif ischar(data) && isvector(data)
        result = java.lang.String(data);
    elseif ~isscalar(data)
        error("dump:ArrayNotSupported", "Non-cell arrays are not supported. Use 1D cells to represent array data.")
    elseif isstruct(data)
        result = convertStruct(data);
    elseif isfloat(data)
        result = java.lang.Double(data);
    elseif isinteger(data)
        result = java.lang.Integer(data);
    elseif islogical(data)
        result = java.lang.Boolean(data);
    elseif isstring(data)
        result = java.lang.String(data);
    else
        error("dump:TypeNotSupported", "Data type '%s' is not supported.", class(data))
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
        error("dump:NonVectorCellNotSupported", "Non-vector cell arrays are not supported. Use nested cells instead.")
    end
    result = java.util.ArrayList();
    for i = 1:length(data)
        result.add(convert(data{i}));
    end
end

function initSnakeYaml
    snakeYamlFile = fullfile(fileparts(mfilename('fullpath')), 'snakeyaml', 'snakeyaml-1.30.jar');
    if ~ismember(snakeYamlFile, javaclasspath('-dynamic'))
        javaaddpath(snakeYamlFile);
    end
end

function opts = getDumperOptions(style)
    import org.yaml.snakeyaml.*;
    opts = DumperOptions();    
    classes = opts.getClass.getClasses;
    styleFields = classes(4).getDeclaredFields();
    styleIndex = find(style == ["flow", "block", "auto"]);
    opts.setDefaultFlowStyle(styleFields(styleIndex).get([]));
end
