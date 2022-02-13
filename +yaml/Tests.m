classdef Tests < matlab.unittest.TestCase

    methods(TestClassSetup)
    
    end

    methods(TestMethodSetup)
    
    end

    methods(Test)
    
        function testParseing(testCase)
            
            data = {
                "", []
                "test", "test"
                "1.23", 1.23
                "True", true
                "[1, 2, True, test]", {1, 2, true, "test"}
                "{}", struct()
                sprintf("12!: 1\n12$: 2"), struct("x12_", 1, "x12__1", 2)
                sprintf("a: test\nb: 123\nc:\n  d: test2\n  e: False"), struct("a", "test", "b", 123, "c", struct("d", "test2", "e", false))
            };
            

            for iTest = 1:height(data)
                
                [s, expected] = data{iTest, :};

                actual = parseYaml(s);
                testCase.verifyEqual(actual, expected);

            end

        end
    end

end