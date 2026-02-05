# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'YAML for MATLAB'
copyright = '2022-2026, Martin Koch and Fernando N. Santos-Navarro'
author = 'Martin Koch and Fernando N. Santos-Navarro'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = ['sphinxcontrib.matlab', 'sphinx.ext.autodoc',
              'sphinx.ext.napoleon', 'sphinx_copybutton']

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'shibuya'
html_static_path = ['_static']
html_theme_options = {
    "color_mode": "light",   # forces light mode by default
}

# -- MATLAB ------------------------------------------------------------------

primary_domain = "mat"
matlab_src_dir = "../"
matlab_auto_link = "basic"
matlab_short_links = False
matlab_show_property_default_value = True
matlab_show_property_specs = True
matlab_class_signature = True

# -- Copybutton -------------------------------------------------------------

copybutton_prompt_text = ">> "
copybutton_exclude = ".linenos, .gp"
