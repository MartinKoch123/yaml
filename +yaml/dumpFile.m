function dumpFile(filePath, data, style)
% Serialize MATLAB data to a YAML file.
%
%   :code:`yaml.dumpFile(filePath, data)` serializes MATLAB variable :code:`data`
%   to a YAML document and writes it to the file specified by :code:`filePath`.
%
%   :code:`yaml.dumpFile(filePath, data, style)` specifies the YAML formatting 
%   style.
%
%   Parameters
%   ----------
%   filePath : string
%     Path of the YAML file to write. Parent directories are created
%     automatically if they do not exist.
%
%   data : any
%     The MATLAB variable to be serialized.
%
%   style: {'auto', 'block', 'flow'}, default='auto'
%     Output style for YAML sequences and mappings:
%       - 'auto' (default) : Automatically choose best fit.
%       - 'block' : Human-readable multi-line (standard YAML).
%       - 'flow' : Compact inline style (JSON-like).
%
%   Notes
%   -----
%   The following MATLAB types are supported and mapped to YAML types:
%
%   +------------------------+-----------------------+
%   | MATLAB type            | YAML type             |
%   +========================+=======================+
%   | 1D cell array          | Sequence              |
%   +------------------------+-----------------------+
%   | 1D non-scalar array    | Sequence              |
%   +------------------------+-----------------------+
%   | 2D/3D cell array       | Nested sequences      |
%   +------------------------+-----------------------+
%   | 2D/3D non-scalar array | Nested sequences      |
%   +------------------------+-----------------------+
%   | struct                 | Mapping               |
%   +------------------------+-----------------------+
%   | scalar single/double   | Floating-point number |
%   +------------------------+-----------------------+
%   | scalar int8/../int64   | Integer               |
%   +------------------------+-----------------------+
%   | scalar uint8/../uint64 | Integer               |
%   +------------------------+-----------------------+
%   | scalar logical         | Boolean               |
%   +------------------------+-----------------------+
%   | scalar string          | String                |
%   +------------------------+-----------------------+
%   | char vector            | String                |
%   +------------------------+-----------------------+
%   | any 0-by-0 value       | null                  |
%   +------------------------+-----------------------+
%
%   Array conversion can be ambiguous. To ensure consistent conversion
%   behaviour, consider manually converting array data to nested 1D cells
%   before converting it to YAML.
%
%   Examples
%   --------
%   >>> data.a = 1;
%   >>> data.b = {"text", false};
%   >>> yaml.dumpFile("test.yaml", data);
%
%   See Also
%   --------
%   yaml.load
%   yaml.loadFile
%   yaml.dump

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
