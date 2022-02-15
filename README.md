# yaml
[YAML](https://yaml.org/) parser and emitter for MATLAB. 
Based on [SnakeYAML](https://bitbucket.org/snakeyaml/snakeyaml/src/master/) and inspired by [yamlmatlab](https://code.google.com/archive/p/yamlmatlab/).

## Example
### Parse and emit
```Matlab
>> data.a = 1.23;
>> data.b = "hello";
>> data.c = {2, {true, 'hola'}};

>> s = yaml.dump(data)

    "a: 1.23
     b: hello
     c:
     - 2.0
     - [true, hola]
     "
   
>> result = yaml.load(s)

  struct with fields:

    a: 1.2300
    b: "hello"
    c: {[2]  {1×2 cell}}
```

### Read and write files
```Matlab
>> yaml.dumpFile("test.yaml", data)
>> result = yaml.loadFile("test.yaml")

  struct with fields:

    a: 1.2300
    b: "hello"
    c: {[2]  {1×2 cell}}
```
## Installation
Extract files and add them to your MATLAB search path.
