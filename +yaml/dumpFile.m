function dumpFile(filePath, data)
% DUMPFILE Write data to YAML file.

arguments
    filePath (1, 1) string {mustBeNonzeroLengthText}
    data
end

% Create YAML string.
yamlString = yaml.dump(data);

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