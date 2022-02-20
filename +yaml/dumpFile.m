function dumpFile(filePath, data, style)
% DUMPFILE Write data to YAML file.

arguments
    filePath (1, 1) string
    data
    style {mustBeMember(style, ["flow", "block", "auto"])} = "auto"
end

% Create YAML string.
yamlString = yaml.dump(data, style);

% Create folder.
folder = fileparts(filePath);
if strlength(folder) > 1 && ~isfolder(folder)
    mkdir(folder);
end

% Write file.
[fid, msg] = fopen(filePath, "wt");
if fid == -1
    error(msg)
end
fprintf(fid, "%s", yamlString);
fclose(fid);

end