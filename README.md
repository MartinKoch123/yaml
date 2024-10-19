# yaml
[YAML 1.1](https://yaml.org/spec/1.1/) parser and emitter for MATLAB R2019b or newer. Based on [SnakeYAML 1.30](https://bitbucket.org/snakeyaml/snakeyaml/src/master/).

[![View yaml on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/106765-yaml)

## Examples
### Load and dump
```Matlab
>> matlabData.a = [1.23; 4.56];
>> matlabData.b = {int32(2), {true, "hello", []}};

>> yamlString = yaml.dump(matlabData)
    "a: [1.23, 4.56]
     b:
     - 2
     - [true, hello, null]
     "
   
>> matlabData = yaml.load(yamlString)
    a: {[1.2300]; [4.5600]}
    b: {[2]; {3×1 cell}}
```

### Read and write files
```Matlab
>> yaml.dumpFile("test.yaml", matlabData)
>> matlabData = yaml.loadFile("test.yaml")
    a: {[1.2300]; [4.5600]}
    b: {[2]; {3×1 cell}}
```

### Styles
```Matlab
>> yamlString = yaml.dump(matlabData, "auto")  % default
    "a: [1.23, 4.56]
     b:
     - 2
     - [true, hello, null]
     "
     
>> yamlString = yaml.dump(matlabData, "block")
    "a: 
     - 1.23
     - 4.56
     b:
     - 2
     - - true
       - hello
       - null
     "
     
>> yamlString = yaml.dump(matlabData, "flow")
    "{a: [1.23, 4.56], b: [2, [true, hello, 'null']], c: [2, [true, hola]]}
     "
```
### YAML null
YAML `null` values are represented by empty Matlab arrays of any type with *all* sizes equal zero.
```Matlab
>> result = yaml.load("null")
    []
    
>> s = yaml.dump([])
    "null
     "
```

### Load as array
Use the `ConvertToArray` option to convert uniform YAML sequences to MATLAB non-cell arrays.
```Matlab
>> yaml.load("[[1, 2], [3, 4]]")
    2×1 cell array

      {2×1 cell}
      {2×1 cell}

>> yaml.load("[[1, 2], [3, 4]]", "ConvertToArray", true)
    1     2
    3     4
```

### Unexpected behaviour for array data

In MATLAB, there is no difference between a scalar and a one-element sequence. This can lead to unintended behaviour when using standard non-cell arrays since information about the data structure can be lost when loading and dumping data. For example, `yaml.dump(1)` will write the YAML string `"1.0"` even though you might have intended to write a sequence with one element `"[1.0]"`. 

To avoid these ambiguities
 - convert all you array data to _nested vector cells_ before dumping and
 - load all data _without_ the `ConvertToArray` option.

## Contributors

Thanks to the following people for their contributions:

- **[Adam Cooman](https://github.com/AdamCooman)**
