# yaml
[YAML](https://yaml.org/) parser and emitter for MATLAB R2019b or newer. Based on [SnakeYAML](https://bitbucket.org/snakeyaml/snakeyaml/src/master/).

[![View yaml on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/106765-yaml)

## Installation
Extract files and add them to your MATLAB search path.

## Examples
### Load and dump
```Matlab
>> data.a = 1.23;
>> data.b = {int32(2), {true, "hello", yaml.Null}};

>> s = yaml.dump(data)
    "a: 1.23
     b:
     - 2
     - [true, hello, null]
     "
   
>> result = yaml.load(s)
    a: 1.2300
    b: {[2]  {1×3 cell}}
```

### Read and write files
```Matlab
>> yaml.dumpFile("test.yaml", data)
>> result = yaml.loadFile("test.yaml")
    a: 1.2300
    b: {[2]  {1×3 cell}}
```

### Styles
```Matlab
>> s = yaml.dump(data, "auto")  % default
    "a: 1.23
     b:
     - 2
     - [true, hello, null]
     "
     
>> s = yaml.dump(data, "block")
    "a: 1.23
     b:
     - 2
     - - true
       - hello
       - null
     "
     
>> s = yaml.dump(data, "flow")
    "{a: 1.23, b: [2, [true, hello, null]]}
     "
```
### YAML null
```Matlab
>> result = yaml.load("null")
    Null
    
>> yaml.isNull(result)
   1
   
>> s = yaml.dump(yaml.Null)
    "null
     "
```
### MATLAB arrays
Since a MATLAB scalar is simultaneously a one-element sequence, non-scalar arrays are not allowed to guarantee consistent conversion behaviour. Use MATLAB cells to create YAML sequences.
```Matlab
>> arrayData = [1, 2, 3];
>> cellData = num2cell(arrayData);
>> s = yaml.dump(cellData)
    "[1.0, 2.0, 3.0]
     "

>> cellResult = yaml.load(s);
>> arrayResult = cell2mat(cellResult)
     1     2     3
```

