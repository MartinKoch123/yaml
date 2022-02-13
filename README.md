# yaml
MATLAB YAML parser and emitter based on SnakeYAML 

# Example
```Matlab
>> data.a = "1.23";
>> data.b = {"hello", false};
>> data.c = struct();
>> data.c.c1 = {1, 2};
>> data.c.c2 = {3, {4, 5}};

>> s = yaml.emit(data)

s = 

    "a: '1.23'
     b: [hello, false]
     c:
       c1: [1.0, 2.0]
       c2:
       - 3.0
       - [4.0, 5.0]
     "

>> result = yaml.parse(s)

result = 

  struct with fields:

    a: "1.23"
    b: {["hello"]  [0]}
    c: [1×1 struct]


```
