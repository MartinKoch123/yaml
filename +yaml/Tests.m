classdef Tests < matlab.unittest.TestCase

    methods(Test)    
        function parse(testCase)
            tests = {
                "", []
                "test # comment", "test"
                "1.23", 1.23
                "True", true
                "1", 1
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

        function parse_unsupportedTypes(testCase)
            notSupportedTests = {
                "2022-2-13T01:01:01", "parse:TypeNotSupported"
            };

            for iTest = 1:size(notSupportedTests, 2)                
                [str, errorId] = notSupportedTests{iTest, :};
                func = @() yaml.parse(str);
                testCase.verifyError(func, errorId);
            end
        end

        function emit(testCase)
            tests = {
                "test", sprintf("test\r\n")
                'test', sprintf("test\r\n")
                't', sprintf("t\r\n")
                1.23, sprintf("1.23\r\n")
                int32(1), sprintf("1\r\n")
                true, sprintf("true\r\n")
                struct("a", "test", "b", 123), sprintf("{a: test, b: 123.0}\r\n")
                {1, "test"}, sprintf("[1.0, test]\r\n")
                {1; "test"}, sprintf("[1.0, test]\r\n")
                {1, {2, 3}}, sprintf("- 1.0\r\n- [2.0, 3.0]\r\n")
            };

            for iTest = 1:size(tests, 2)                
                [data, expected] = tests{iTest, :};
                actual = yaml.emit(data);
                testCase.verifyEqual(actual, expected);
            end
        end

        function emit_unsupportedTypes(testCase)
            notSupportedTests = {
                [1, 2], "emit:ArrayNotSupported"
                ["one", "two"], "emit:ArrayNotSupported"
                [false, true], "emit:ArrayNotSupported"
                {1, 2; 3, 4}, "emit:NonVectorCellNotSupported"
                datetime(2022, 2, 13), "emit:TypeNotSupported"
            };

            for iTest = 1:height(notSupportedTests)                
                [data, errorId] = notSupportedTests{iTest, :};
                func = @() yaml.emit(data);
                testCase.verifyError(func, errorId);
            end
        end

        function writeFile(testCase)
            data = struct("a", 1.23, "b", "test");
            expected = sprintf("{a: 1.23, b: test}\r\n");

            testPath = fullfile(fileparts(which("yaml.Tests")), "folder/test.yaml");

            yaml.writeFile(testPath, data)
            actual = string(fileread(testPath));

            testCase.verifyEqual(actual, expected);

            delete(testPath)
            rmdir(fileparts(testPath))
        end

        function readFile(testCase)
            data = struct("a", 1.23, "b", "test");

            testPath = fullfile(fileparts(which("yaml.Tests")), "folder/test.yaml");

            yaml.writeFile(testPath, data)
            actual = yaml.readFile(testPath);

            testCase.verifyEqual(actual, data);

            delete(testPath)
            rmdir(fileparts(testPath))
        end
    end
end