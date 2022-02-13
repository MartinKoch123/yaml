classdef Tests < matlab.unittest.TestCase

    methods(Test)    
        function parse(testCase)
            
            tests = {
                "", []
                "test", "test"
                "1.23", 1.23
                "True", true
                "[1, 2, True, test]", {1, 2, true, "test"}
                "{}", struct()
                sprintf("12!: 1\n12$: 2"), struct("x12_", 1, "x12__1", 2)
                sprintf("a: test\nb: 123\nc:\n  d: test2\n  e: False"), struct("a", "test", "b", 123, "c", struct("d", "test2", "e", false))
            };

            for iTest = 1:height(tests)                
                [s, expected] = tests{iTest, :};
                actual = yaml.parse(s);
                testCase.verifyEqual(actual, expected);
            end
        end

        function emit(testCase)

            tests = {
                "test", sprintf("test\r\n")
                't', sprintf("t\r\n")
                1.23, sprintf("1.23\r\n")
                int32(1), sprintf("1\r\n")
                true, sprintf("true\r\n")
                struct("a", "test", "b", 123), sprintf("{a: test, b: 123.0}\r\n")
                {1, "test"}, sprintf("[1.0, test]\r\n")
                {1; "test"}, sprintf("[1.0, test]\r\n")
                {1, {2, 3}}, sprintf("- 1.0\r\n- [2.0, 3.0]\r\n")
            };

            for iTest = 1:height(tests)                
                [data, expected] = tests{iTest, :};
                actual = yaml.emit(data);
                testCase.verifyEqual(actual, expected);
            end

            notSupportedTests = {
                'test', "emit:ArrayNotSupported"
                [1, 2], "emit:ArrayNotSupported"
                ["one", "two"], "emit:ArrayNotSupported"
                [false, true], "emit:ArrayNotSupported"
                {1, 2; 3, 4}, "emit:NonVectorCellNotSupported"
            };

            for iTest = 1:height(notSupportedTests)                
                [data, errorId] = notSupportedTests{iTest, :};
                func = @() yaml.emit(data);
                testCase.verifyError(func, errorId);
            end
        end
    end
end