function initializeSnakeYaml
%INITIALIZESNAKEYAML Make the bundled SnakeYAML JAR available to MATLAB.
%   INITIALIZESNAKEYAML takes no inputs and returns no outputs. If the
%   bundled JAR is not already on MATLAB's Java classpath, this function
%   appends its absolute path to <prefdir>/javaclasspath.txt for future
%   sessions and adds it to the dynamic Java classpath for this session.
%   MATLAB must be restarted before the appended static-classpath entry is
%   used. Existing static-classpath file content is preserved unchanged.
%
%   Side effects include creating or appending to javaclasspath.txt and
%   modifying the current session's dynamic Java classpath.
%
%   Warnings:
%     yaml:initialization:RestartForFasterStartup
%       The static-classpath entry was appended and will be used after a
%       MATLAB restart.
%     yaml:initialization:StaticClasspathUnavailable
%       The preferences file could not be updated. The dynamic-classpath
%       fallback is still attempted for the current session.
%
%   See also JAVACLASSPATH, JAVAADDPATH, PREFDIR.

    arguments
        % This function accepts no input arguments.
    end

    snakeYamlJarName = 'snakeyaml-1.30.jar';
    privateDirectory = fileparts(mfilename('fullpath'));
    yamlPackageDirectory = fileparts(privateDirectory);
    snakeYamlFile = fullfile( ...
        yamlPackageDirectory, 'snakeyaml', snakeYamlJarName);

    javaClasspath = javaclasspath('-all');
    if any(strcmp(snakeYamlFile, javaClasspath))
        return;
    end

    staticClasspathFile = '<prefdir>/javaclasspath.txt';
    staticClasspathUpdated = false;
    staticClasspathUpdateMessage = '';

    try
        staticClasspathFile = fullfile(prefdir(), 'javaclasspath.txt');
        [staticClasspathFileId, openMessage] = fopen(staticClasspathFile, 'a+');
        if staticClasspathFileId < 0
            error('yaml:initialization:StaticClasspathIO', ...
                'Could not open the file for append/update: %s', openMessage);
        end
        fileCleanup = onCleanup(@() closeStaticClasspathFile( ...
            staticClasspathFileId, staticClasspathFile));

        seekStatus = fseek(staticClasspathFileId, 0, 'eof');
        if seekStatus ~= 0
            seekErrorMessage = ferror(staticClasspathFileId);
            error('yaml:initialization:StaticClasspathIO', ...
                'Could not seek to the end of the file: %s', ...
                seekErrorMessage);
        end
        staticClasspathFileLength = ftell(staticClasspathFileId);
        if staticClasspathFileLength < 0
            error('yaml:initialization:StaticClasspathIO', ...
                'Could not determine the file length: %s', ...
                ferror(staticClasspathFileId));
        end

        carriageReturn = uint8(13); % CR line-ending byte.
        lineFeed = uint8(10); % LF line-ending byte.
        separatorNeeded = false;
        if staticClasspathFileLength > 0
            seekStatus = fseek(staticClasspathFileId, -1, 'eof');
            if seekStatus ~= 0
                seekErrorMessage = ferror(staticClasspathFileId);
                error('yaml:initialization:StaticClasspathIO', ...
                    'Could not seek to the final byte of the file: %s', ...
                    seekErrorMessage);
            end
            [lastByte, bytesRead] = fread(staticClasspathFileId, 1, '*uint8');
            if bytesRead ~= 1
                error('yaml:initialization:StaticClasspathIO', ...
                    'Could not read the final byte of the file: %s', ...
                    ferror(staticClasspathFileId));
            end
            separatorNeeded = lastByte ~= carriageReturn && lastByte ~= lineFeed;
        end

        seekStatus = fseek(staticClasspathFileId, 0, 'eof');
        if seekStatus ~= 0
            seekErrorMessage = ferror(staticClasspathFileId);
            error('yaml:initialization:StaticClasspathIO', ...
                'Could not restore the append position: %s', ...
                seekErrorMessage);
        end
        if separatorNeeded
            textToAppend = [char(lineFeed), snakeYamlFile, char(lineFeed)];
        else
            textToAppend = [snakeYamlFile, char(lineFeed)];
        end
        bytesToAppend = unicode2native(textToAppend, 'UTF-8');
        bytesWritten = fwrite(staticClasspathFileId, bytesToAppend, 'uint8');
        if bytesWritten ~= numel(bytesToAppend)
            error('yaml:initialization:StaticClasspathIO', ...
                'Wrote %d of %d required bytes: %s', bytesWritten, ...
                numel(bytesToAppend), ferror(staticClasspathFileId));
        end

        writeErrorMessage = ferror(staticClasspathFileId);
        if ~isempty(writeErrorMessage)
            error('yaml:initialization:StaticClasspathIO', ...
                'Could not append the JAR path: %s', writeErrorMessage);
        end
        closeStatus = fclose(staticClasspathFileId);
        if closeStatus ~= 0
            error('yaml:initialization:StaticClasspathIO', ...
                'Could not flush and close the file after appending.');
        end
        clear fileCleanup;
        staticClasspathUpdated = true;
    catch updateException
        staticClasspathUpdateMessage = updateException.message;
        if exist('fileCleanup', 'var')
            clear fileCleanup;
        end
    end

    javaaddpath(snakeYamlFile);

    if staticClasspathUpdated
        warning('yaml:initialization:RestartForFasterStartup', ...
            ['The bundled SnakeYAML JAR was added to the static Java ' ...
            'classpath file "%s". Restart MATLAB to use the static ' ...
            'classpath entry.'], staticClasspathFile);
    else
        warning('yaml:initialization:StaticClasspathUnavailable', ...
            ['Could not update the static Java classpath file "%s": %s. ' ...
            'The bundled JAR was added dynamically for this session.'], ...
            staticClasspathFile, staticClasspathUpdateMessage);
    end

end

function closeStaticClasspathFile(fileId, expectedFile)
%CLOSESTATICCLASSPATHFILE Close an initializer file that remains open.
%   CLOSESTATICCLASSPATHFILE(FILEID, EXPECTEDFILE) takes an open MATLAB file
%   identifier FILEID and its expected path EXPECTEDFILE. It closes the file
%   only when FILEID still refers to EXPECTEDFILE, allowing onCleanup to
%   cover exceptional paths without repeating a verified explicit close.
%   This function returns no outputs.

    arguments
        fileId (1, 1) double % Identifier returned by fopen.
        expectedFile (1, :) char % Expected path for the open file.
    end

    try
        openFile = fopen(fileId);
    catch
        return;
    end
    if strcmp(openFile, expectedFile)
        fclose(fileId);
    end
end
