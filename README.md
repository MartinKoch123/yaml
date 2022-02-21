# yaml
[YAML](https://yaml.org/) parser and emitter for MATLAB R2019b or newer.
 
Based on [SnakeYAML](https://bitbucket.org/snakeyaml/snakeyaml/src/master/) and inspired by [yamlmatlab](https://code.google.com/archive/p/yamlmatlab/).

[![View yaml on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/106765-yaml)

## Example
### Load and dump
```Matlab
>> data.a = 1.23;
>> data.b = "hello";
>> data.c = {2, {true, 'world'}, yaml.Null};

>> s = yaml.dump(data)

    "a: 1.23
     b: hello
     c:
     - 2.0
     - [true, world]
     - null
     "
   
>> result = yaml.load(s)

  struct with fields:

    a: 1.2300
    b: "hello"
    c: {[2]  {1×2 cell}  [1×1 yaml.Null]}
```

### Read and write files
```Matlab
>> yaml.dumpFile("test.yaml", data)
>> result = yaml.loadFile("test.yaml")

  struct with fields:

    a: 1.2300
    b: "hello"
    c: {[2]  {1×2 cell}  [1×1 yaml.Null]}
```
## Installation
Extract files and add them to your MATLAB search path.

## Notes
- Requires R2019b or newer.
- Non-scalar, non-cell arrays are not supported to avoid the scalar/list ambiguity. Use 1D cells to represent sequences.
- Set the output style for `yaml.dump` and `yaml.dumpFile` with an optional argument value `"auto"`, `"block"` `"flow"`. Example: `yaml.dump(data, "block")`