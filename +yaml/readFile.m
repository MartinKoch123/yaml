function result = readFile(filePath)
% READFILE Read YAML file.
%   Read a YAML file and convert the content to appropriate data types.

arguments
    filePath (1, 1) string {mustBeFile}
end

content = string(fileread(filePath));
result = yaml.parse(content);

end