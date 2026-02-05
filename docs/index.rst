YAML for MATLAB
===============

`YAML for MATLAB <https://github.com/MartinKoch123/yaml>`_ allows you to read and write YAML files directly from MATLAB. It supports `YAML 1.1 <https://yaml.org/spec/1.1/>`_ and is compatible with MATLAB R2019b and newer.

Consider using this package if you want to:

- use YAML as a configuration format for MATLAB applications
- exchange structured data with other languages and tools
- store human-readable data files alongside your MATLAB projects.

The package is built on top of the `SnakeYAML v1.30 <https://bitbucket.org/snakeyaml/snakeyaml/src/master/>`_ Java library, wrapped in a MATLAB-friendly interface that requires no Java knowledge from the user.

Installation
------------

1. Download the package from one of the following sources:

   - `GitHub Repository <https://github.com/MartinKoch123/yaml>`_
   - `MATLAB File Exchange <https://www.mathworks.com/matlabcentral/fileexchange/106765-yaml>`_

2. Place the :code:`+yaml` folder in a directory of your choice.
3. Add that directory to your MATLAB path.

Quick Start
-----------

.. code-block:: matlab
  :caption: Dump MATLAB data to a YAML string

  >> data.a = 1;
  >> data.b = {"hello", false};
  >> str = yaml.dump(data)

  str = 
  
      "a: 1.0
       b: [hello, false]
       "

.. code-block:: matlab
  :caption: Dump MATLAB data to a YAML file
  
  >> data.a = 1;
  >> data.b = {"text", false};
  >> yaml.dumpFile("test.yaml", data);

.. code-block:: matlab
  :caption: Load a YAML string into MATLAB data types

  >> str = "{a: 1, b: [text, false]}";
  >> result = yaml.load(str)

  result = 

  struct with fields:

    a: 1
    b: {["test"] [0]}

.. code-block:: matlab
  :caption: Load a YAML file into MATLAB data types

  >> data.a = 1;
  >> data.b = {"text", false};
  >> yaml.dumpFile("test.yaml", data);
  >> result = yaml.loadFile("test.yaml")

  result = 

  struct with fields:

    a: 1
    b: {["test"] [0]}

Credits and License
-------------------

- **Core Package Author:** `Martin Koch <https://github.com/MartinKoch123>`_
- **Core Package Contributor:** `Adam Cooman <https://github.com/AdamCooman>`_
- **Documentation Author:** `Fernando N. Santos-Navarro <https://github.com/fernandonobel>`_
- **License:** The code and this documentation are provided under the `MIT License <https://opensource.org/licenses/MIT>`_.

.. toctree::
   :hidden:

   Home <self>
   Tutorials <tutorials/index>
   How-to Guides <how_to/index>
   API Reference <apidocs/index>
   Explanations <explanations/index>
   GitHub Repository <https://github.com/MartinKoch123/yaml>
   MATLAB File Exchange <https://www.mathworks.com/matlabcentral/fileexchange/106765-yaml>
