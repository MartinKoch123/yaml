How to maintain YAML configurations without duplication
=======================================================

.. admonition:: Goal

  Create and maintain YAML configuration files that share a common base while avoiding duplication of configuration code.

This guide presents three options to define a base YAML configuration file and extend it to create case-specific variants, such as development, production, or testing. Each option is illustrated with an example that starts from a base MATLAB simulation configuration and extends it into a high-precision configuration, inheriting from the base while overriding specific parameters.

**Prerequisites:**

- MATLAB R2019b or later.
- `YAML for MATLAB <https://github.com/MartinKoch123/yaml>`_ package v1.6.0, installed and added to the path.
- Intermediate familiarity with YAML syntax.

**Options summary:**

+-----------------------------+-------------+---------------------------------------------------------+
| Option                      | Scalability | Use this is you want...                                 |
+=============================+=============+=========================================================+
| :ref:`yaml-merge-keys`      | Low         | to keep everything in a single config file              |
+-----------------------------+-------------+---------------------------------------------------------+
| :ref:`implicit-composition` | Medium      | to have separate config files                           |
+-----------------------------+-------------+---------------------------------------------------------+
| :ref:`explicit-composition` | High        | to have complex inheritance chains between config files |
+-----------------------------+-------------+---------------------------------------------------------+

.. _yaml-merge-keys:

YAML merge keys
---------------

How to implement
^^^^^^^^^^^^^^^^

1. Create a single YAML file to store all configuration cases.
2. Define the shared base configuration in that file.
3. Use YAML anchors and merge keys to derive the remaining configurations in that file.
4. Load the file with :code:`yaml.loadFile()`.
5. Select the required configuration from the loaded data.

Example
^^^^^^^

Create a single YAML, :code:`config.yaml`, to store all the configuration cases. Define the shared configuration in that file in the :code:`default` field. Use YAML anchors (:code:`&default` and :code:`&solver_options`) and merge keys (:code:`<<: *default` and :code:`<<: *solver_options`) to derive base and high-precicion configurations in :code:`base` and :code:`high_precision` fields.

.. code-block:: yaml
  :caption: config.yaml
  :linenos:

  default: &default
    odefun: exponential_decay
    tspan: [0, 10]
    y0: 1
    solver: ode45
    solver_options: &solver_options
      RelTol: 1.0e-3
      AbsTol: 1.0e-6
      MaxStep: 0.1
      InitialStep: 0.01
  
  base:
    <<: *default
  
  high_precision:
    <<: *default
    solver_options:
      <<: *solver_options
      RelTol: 1.0e-6
      AbsTol: 1.0e-9

Load the :code:`config.yaml` with :code:`yaml.loadFile()` and select the required configuration from the loaded data:

.. code-block:: matlab

  config = yaml.loadFile("config.yaml", "ConvertToArray", true);
  
  % Load base configuration.
  cfg = config.base;
  
  % Load high-precision configuration.
  cfg = config.high_precision;


.. _implicit-composition:

Implicit composition
--------------------

How to implement
^^^^^^^^^^^^^^^^

1. Create a YAML file that defines the base configuration.
2. Put all shared configuration values in that file.
3. Create a separate YAML file for each configuration case.
4. In each case-specific file, define only the values that differ from the base.
5. Select an external tool or implement a custom function to load the base configuration and apply the case-specific overrides.
6. Load the required configuration using that tool or function.

Example
^^^^^^^

Create a YAML file, :code:`base.yaml`, with the base configuration values.

.. code-block:: yaml
  :caption: base.yaml
  :linenos:

  odefun: exponential_decay
  tspan: [0, 10]
  y0: 1
  solver: ode45
  solver_options:
    RelTol: 1.0e-3
    AbsTol: 1.0e-6
    MaxStep: 0.1
    InitialStep: 0.01

Create a separate YAML file, :code:`high_precision.yaml`, defining only the values that differ from the :code:`base.yaml`:

.. code-block:: yaml
  :caption: high_precision.yaml
  :linenos:

  solver_options:
    RelTol: 1.0e-6
    AbsTol: 1.0e-9

Implement the following custom funtion, :code:`mergeStructs()`, to override the base configuration with the high-precision configuration.

.. code-block:: matlab
  :caption: mergeStructs.m
  :linenos:

  function [result] = mergeStructs(override, base)
  %MERGESTRUCTS Recursively merge two structures.
  %
  %   RESULT = MERGESTRUCTS(OVERRIDE, BASE) returns a structure where fields
  %   in OVERRIDE replace those in BASE and nested structs are also merged
  %   recursively.
  
      result = base;
  
      for fn = fieldnames(override)'
          field = fn{1};
      
          if isfield(result, field) && isstruct(result.(field)) ...
              && isstruct(override.(field))
              % Recursively merge nested structs.
              result.(field) = mergeStructs(override.(field), result.(field));
          else
              % Override or add new field.
              result.(field) = override.(field);
          end
      end
  end

Load the required configuration using :code:`yaml.loadFile()` and :code:`mergeStructs()`:

.. code-block:: matlab

  % For loading base configuration.
  cfg = yaml.loadFile("base.yaml", "ConvertToArray", true);
  
  % For loading high-precision configuration.
  base = yaml.loadFile("base.yaml", "ConvertToArray", true);
  high_precision = yaml.loadFile("high_precision.yaml", "ConvertToArray", true);
  cfg = mergeStructs(high_precision, base);

.. _explicit-composition:

Explicit composition
--------------------

How to implement
^^^^^^^^^^^^^^^^

1. Create a separate YAML file for each base configuration.
2. Define all values for each base configuration case in its file.
3. Create a separate YAML file for each extended configuration.
4. In each extended configuration file, explicitly specify which base configuration it extends and define only the values that differ from that base.
5. Implement a custom function to load configurations, taking extensions into account.
6. Load the required configuration using this custom function.

Example
^^^^^^^

Create a YAML file, :code:`base.yaml`, and define the base configuration:

.. code-block:: yaml
  :caption: base.yaml
  :linenos:

  odefun: exponential_decay
  tspan: [0, 10]
  y0: 1
  solver: ode45
  solver_options:
    RelTol: 1.0e-3
    AbsTol: 1.0e-6
    MaxStep: 0.1
    InitialStep: 0.01

Create a YAML file, :code:`high_precision.yaml`, define it is a extension of :code:`base.yaml` writing :code:`extends: base.yaml` and define the only the values that differ from :code:`base.yaml`.

.. code-block:: yaml
  :caption: high_precision.yaml
  :linenos:

  extends: base.yaml
  solver_options:
    RelTol: 1.0e-6
    AbsTol: 1.0e-9

Implement the custom function, :code:`loadSimulationConfig()`, to load a configuration file taking extensions into account.

.. code-block:: matlab
  :caption: loadSimulationConfig.m
  :linenos:

  function [config] = loadSimulationConfig(filename)
  %LOADSIMULATIONCONFIG Load a simulation configuration from a YAML file.
  %
  %   CONFIG = LOADSIMULATIONCONFIG(FILENAME) loads the YAML configuration
  %   stored in FILENAME. If the configuration contains an 'extends' field,
  %   the parent configuration is loaded and merged recursively.
  
      % Load the configuration from YAML file.
      config = yaml.loadFile(filename, "ConvertToArray", true);
      
      % Merge with parent config if 'extends' is specified
      if isfield(config, "extends")
          parentConfig = loadSimulationConfig(config.extends);
          config = rmfield(config, "extends");
          config = mergeStructs(config, parentConfig);
      end
  end

Load the required configuration file with :code:`loadSimulationConfig()`:

.. code-block:: matlab

  % Load base configuration.
  cfg = loadSimulationConfig("base.yaml");

  % Load high-precision configuration.
  cfg = loadSimulationConfig("high_precision.yaml");

Appendix
--------


Here is the ODE function definition:

.. code-block:: matlab
  :caption: exponential_decay.m
  :linenos:

  function dydt = exponential_decay(t, y)
  %EXPONENTIAL_DECAY Simple first-order ODE.
  %
  %   dydt = EXPONENTIAL_DECAY(t, y) returns the time derivative of y
  %   for the equation: dy/dt = -k*y, where k is the decay rate.
  
      k = 0.5;
      dydt = -k*y;
  end

Here is how to run a simulation with the loaded configuration:

.. code-block:: matlab

  % Use the selected configuration for the simulator.
  solver = str2func(cfg.solver);
  odefun = str2func(cfg.odefun);
  [t, y] = solver(odefun, cfg.tspan, cfg.y0, cfg.solver_options);
