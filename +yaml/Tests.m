classdef Tests < matlab.unittest.TestCase

    methods(Test)    
        function load(testCase)
            tests = {
                "test # comment", "test"
                "1.23", 1.23
                "True", true
                "1", 1
                "[1, 2, True, test]", {1, 2, true, "test"}
                "{}", struct()
                sprintf("12!: 1\n12$: 2"), struct("x12_", 1, "x12__1", 2)
                sprintf("a: test\nb: 123\nc:\n  d: test2\n  e: False"), struct("a", "test", "b", 123, "c", struct("d", "test2", "e", false))
            };

            for iTest = 1:size(tests, 1)                
                [s, expected] = tests{iTest, :};
                actual = yaml.load(s);
                testCase.verifyEqual(actual, expected);
            end
        end

        function load_unsupportedTypes(testCase)
            tests = {
                "2022-2-13T01:01:01", "load:TypeNotSupported"
                "", "MATLAB:validators:mustBeNonzeroLengthText"
            };

            for iTest = 1:size(tests, 1)                
                [str, errorId] = tests{iTest, :};
                func = @() yaml.load(str);
                testCase.verifyError(func, errorId);
            end
        end

        function dump(testCase)
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

            for iTest = 1:size(tests, 1)                
                [data, expected] = tests{iTest, :};
                actual = yaml.dump(data);
                testCase.verifyEqual(actual, expected);
            end
        end

        function dump_unsupportedTypes(testCase)
            tests = {
                [1, 2], "dump:ArrayNotSupported"
                ["one", "two"], "dump:ArrayNotSupported"
                [false, true], "dump:ArrayNotSupported"
                {1, 2; 3, 4}, "dump:NonVectorCellNotSupported"
                datetime(2022, 2, 13), "dump:TypeNotSupported"
            };

            for iTest = 1:size(tests, 1)                
                [data, errorId] = tests{iTest, :};
                func = @() yaml.dump(data);
                testCase.verifyError(func, errorId);
            end
        end

        function dumpFile(testCase)
            data = struct("a", 1.23, "b", "test");
            expected = sprintf("{a: 1.23, b: test}\r\n");

            testPath = fullfile(fileparts(which("yaml.Tests")), "folder/test.yaml");

            yaml.dumpFile(testPath, data)
            actual = string(fileread(testPath));

            testCase.verifyEqual(actual, expected);

            delete(testPath)
            rmdir(fileparts(testPath))
        end

        function loadFile(testCase)
            data = struct("a", 1.23, "b", "test");

            testPath = fullfile(fileparts(which("yaml.Tests")), "folder/test.yaml");

            yaml.dumpFile(testPath, data)
            actual = yaml.loadFile(testPath);

            testCase.verifyEqual(actual, data);

            delete(testPath)
            rmdir(fileparts(testPath))
        end
    end
end