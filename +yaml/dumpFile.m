function dumpFile(filePath, data, options)
% DUMPFILE Write data to YAML file.

arguments
    filePath (1, 1) string {mustBeNonzeroLengthText}
    data
    options.Style {mustBeMember(options.Style, ["flow", "block", "auto"])} = "auto"
end

% Create YAML string.
yamlString = yaml.dump(data, "Style", options.Style);

% Create folder.
folder = fileparts(filePath);
if strlength(folder) > 1 && ~isfolder(folder)
    mkdir(folder);
end

% Write file.
[fid, msg] = fopen(filePath, "w");
if fid == -1
    error(msg)
end
fprintf(fid, "%s", yamlString);
fclose(fid);

end