function initSnakeYaml

snakeYamlFile = [fileparts(mfilename('fullpath')) '\snakeyaml-1.30.jar'];
if ~ismember(snakeYamlFile, javaclasspath('-dynamic'))
    javaaddpath(snakeYamlFile);
end

end