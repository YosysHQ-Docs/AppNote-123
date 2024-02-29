AppNote 123
===========

This application note provides a guided example of how to use SBY with large and
complex designs; looking at how to configure the tools and the limitations
therein.

.. note:: **The source code for this application note is provided in:**

    -  **Link to github repo** https://github.com/YosysHQ-Docs/AppNote-123

    Also, **Tabby CAD Suite is highly recommended! Ask us for an evaluation
    license:** https://www.yosyshq.com/contact

In general, the steps for verifying a design are as follows:

#. Create a new folder
#. Copy/clone design source to folder
#. Run ``sby --init-config-file <name>``
#. Add source files to ``[files]`` section
#. Update ``[script]`` section to read source files and prepare top level
    module
#. Run ``sby <name>.sby``
    #. Remove or ignore any sections of code which raise errors in parsing
    #. Re-run with ``sby -f <name.sby>`` to ignore existing folder
#. Setup clock/reset and any other inputs which need to be constrained
#. Remove or convert unwanted properties
#. Cutpoint multipliers, memories, and any other difficult-to-prove logic
#. Add tasks for cover/prove modes
#. Perform any other configuration steps needed
#. Run ``sby -f <name>.sby [task]``

.. toctree::
    :caption: Examples

    veer
    cv32
