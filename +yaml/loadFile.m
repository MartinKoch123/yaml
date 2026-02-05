function result = loadFile(filePath, options)
% Parse a YAML file into MATLAB data types.
%
%   :code:`result = yaml.loadFile(filePath)` reads the YAML document stored at 
%   the :code:`filePath` and converts it into MATLAB data types.
%
%   :code:`result = yaml.loadFile(filePath, options)` allows control over the 
%   conversion behavior using name-value options.
%
%   Parameters
%   ----------
%   filepath : string
%     Path to the YAML file to be parsed.
%
%   options.ConvertToArray : logical, default = false
%     If true, YAML sequences are converted to non-cell MATLAB arrays whenever
%     possible. For example, :code:`result = yaml.load(s, 'ConvertToArray', true)`
%     or :code:`result = yaml.load(s, ConvertToArray=true)`.
%
%   Returns
%   -------
%   result : struct, array, cell or scalar
%     MATLAB representation of the parsed YAML document, with types inferred
%
%   Notes
%   -----
%   
%   The following table summarizes the mapping from YAML types to MATLAB
%   types:
%
%   +----------------------------+------------------------------------------+
%   | YAML type                  | MATLAB type                              |
%   +============================+==========================================+
%   | Sequence                   | cell (or array if ConvertToArray = true) |
%   +----------------------------+------------------------------------------+
%   | Mapping                    | struct                                   |
%   +----------------------------+------------------------------------------+
%   | Floating-point number      | double                                   |
%   +----------------------------+------------------------------------------+
%   | Integer                    | double                                   |
%   +----------------------------+------------------------------------------+
%   | Boolean                    | logical                                  |
%   +----------------------------+------------------------------------------+
%   | String                     | string                                   |
%   +----------------------------+------------------------------------------+
%   | Date (yyyy-mm-ddTHH:MM:SS) | datetime                                 |
%   +----------------------------+------------------------------------------+
%   | Date (yyyy-mm-dd)          | datetime                                 |
%   +----------------------------+------------------------------------------+
%   | null                       | 0-by-0 double                            |
%   +----------------------------+------------------------------------------+
%
%   Examples
%   --------
%   >>> data.a = 1;
%   >>> data.b = {"text", false};
%   >>> yaml.dumpFile("test.yaml", data);
%   >>> yaml.loadFile("test.yaml")
%     struct with fields:
%       a: 1
%       b: {["text"]  [0]}
%
%   See Also
%   --------
%   yaml.load
%   yaml.dump
%   yaml.dumpFile
 
arguments
    filePath (1, 1) string
    options.ConvertToArray (1, 1) logical = false
end

content = string(fileread(filePath));
result = yaml.load(content, "ConvertToArray", options.ConvertToArray);

end
