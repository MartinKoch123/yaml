function initSnakeYaml

snakeYamlFile = fullfile(fileparts(mfilename('fullpath')), 'snakeyaml', 'snakeyaml-1.30.jar');
if ~ismember(snakeYamlFile, javaclasspath('-dynamic'))
    javaaddpath(snakeYamlFile);
end

end