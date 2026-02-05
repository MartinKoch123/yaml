MAT-file vs. YAML: Where storing data ends and configuration begins
===================================================================

When a seasoned MATLAB user encounters YAML for the first time, their most likely reaction is: *Why should I use this if I already have MAT-files?*

It's a fair question. Both formats allow you to save and load variables from files. At a superficial level, they appear to solve the same problem. Therefore, it is not immediately obvious what the difference is between them or what the value proposition of each one really is.

To answer this question, we need to go beyond the problem of data storage and look at the problem of configuring tools and workflows.

In this article, we explore:

- what problem MAT-files solve
- what problem YAML solves
- what happens when these two problems are not kept separate.

MAT-files are the solution for storage
--------------------------------------

The MAT-file format is a propietary binary format, designed by MATLAB, that allows data to be stored and loaded efficiently within MATLAB.

Its main strengths are:

- **Speed.** Fast at reading and writing large volumes of data.
- **Compression.** Efficiently compresses large numerical datasets.
- **Native support.** Seamlessly handles complex MATLAB-specific objects and structures.

However, its binary nature creates "opacity":

- you cannot inspect a MAT-file without using MATLAB
- you cannot easily compare versions of files
- you cannot edit it with a text editor.

MAT-files are bad for configuration
-----------------------------------

This is where we move on to the second problem: configuration. The configuration problem has different requirements than the storing data problem. In configuration, the challenge is not volume of data, but cognitive complexity and change management.

The opacity of MAT-files creates three types of friction in a configuration context:

- **Version control friction.** Git treats MAT-files as "blobs." A :code:`git diff` won't show you which part changed, it only tells you the binary file (as a whole) is different.
- **Editing friction.** To change a single value, you have to launch MATLAB, load the file into memory, modify the variable, and re-save.
- **Interoperability friction.** Using a proprietary binary format makes it difficult to create workflows that involve other languages (such as Python or C++).

.. admonition:: Example
  
  `STRIKE-GOLDD <https://github.com/afvillaverde/strike-goldd>`_ is a MATLAB tool for analyzing state-space models. This tool uses MAT-files for configuration. Specifically, to load the model to be analyzed.
  
  The consequences of using MAT-files for this task are as follows:
  
  - If a colleague updates a model, you can't "diff" the change. You must manually load both files in MATLAB's workspace to compare them.
  - You need an auxiliary MATLAB script just to generate the configuration file because there is no way to write that binary file by hand.
  - There is a Python version of STRIKE-GOLDD, called `StrikePy <https://github.com/afvillaverde/StrikePy>`_. However, the Python version cannot be configured using the same MAT-file as the MATLAB version.

YAML is the solution for configuration
--------------------------------------

YAML is a format designed specifically to solve the configuration problem. Its main advantage is that it is human-readable, which enables:

- **Version control.** Because it is plain text (and not a binary file), it works naturally with version control systems. If someone changes a parameter, Git can show the exact line that was modified.
- **Human editability.** You can open a YAML file in any editor, understand the logic, and make changes instantly.
- **Interoperability.** YAML is a widely adopted industry standard. A YAML file can be easily read in MATLAB, Python, C++, Java, Rust, and many other languages.

.. admonition:: Example

  Returning to STRIKE-GOLDD, if this tool used YAML to configure its models, the consequences would be:
 
  - Changes made by a colleague could be quickly understood using a "diff".
  - Models could be developed directly, using auxiliary scripts only when necessary.
  - Interoperability between the MATLAB and Python versions would be guaranteed from the outset.
  
  In fact, once configuration becomes interoperable, the need to develop the same tool in multiple programming languages decreases, since truly multi-language workflows become possible.

Conclusion: YAML and MAT-files solve different problems
-------------------------------------------------------

+------------------+----------------------------------+--------------------------------+
| Feature          | MAT-file                         | YAML                           |
+==================+==================================+================================+
| Primary Goal     | High-performance data storage    | Human-readable configuration   |
+------------------+----------------------------------+--------------------------------+
| Version Control  | "Blob" (no diffs)                | Line-by-line diffs             |
+------------------+----------------------------------+--------------------------------+
| Editing          | Requires MATLAB                  | Any text editor                |
+------------------+----------------------------------+--------------------------------+
| Interoperability | Proprietary/Limited              | Universal (Python, C++, etc.)  |
+------------------+----------------------------------+--------------------------------+

Data storage and configuration management have opposing requirements. Features that benefit one are irrelevant --- or even harmful --- for the other.

We have seen how opacity is detrimental to configuration. Conversely, human readability is detrimental to storage. If you need to store 2 GB of experimental data, human readability adds no value (no human can read 2 GB of raw experimental data) and actively limits efficiency in reading, writing, and compressing data.

Therefore, although YAML and MAT-files may appear similar on the surface, they are not alternatives to each other. They are responses to different needs. Understanding those needs helps avoid unnecessary debates and bad technical decisions.
