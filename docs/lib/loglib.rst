.. _loglib:

LogLib
======

A library for logging to the screen, which is either the built-in computer screen or a connected monitor of any size.

**Contents:**

* :ref:`Functions <loglib_funcs>`
* :ref:`Local Functions <loglib_localfuncs>`








.. _loglib_funcs:

Functions
---------

* :ref:`init(title, version) <loglib_funcs_init>`
* :ref:`log(tag, msg) <loglib_funcs_log>`

.. _loglib_funcs_init:

init(title, version)
^^^^^^^^^^^^^^^^^^^^

Initializes LogLib with setting the title in the computer and, if a monitor is present, setting the title in the monitor and redirecting output to the monitor.

.. code-block:: lua

    function loglib.init(title, version)
        ...
    end

**Arguments:**

.. list-table::
    :widths: 20 20 20 40
    :header-rows: 1

    * - Name
      - Type
      - Default
      - Description
    * - **title**
      - ``string``
      - ``nil``
      - Title that will be displayed at the top of the screen.
    * - **version**
      - ``string``
      - ``nil``
      - Version that will be displayed at the top of the screen.

**Returns:** ``nil``

**Example:**

.. code-block:: lua

    local loglib = require("loglib")
    loglib.init("Test PC", "V1.0")

This would initialize LogLib and would display the text ``Test PC V1.0`` at the top of the screen.

.. warning:: 
    If a monitor is present, **all** text ouput will be redirected onto the monitor.

.. note:: 
    Screen refers to the active output. If no monitor is present, the active output is the computer screen. If a monitor is present, the active output is the monitor.

----

.. _loglib_funcs_log:

log(tag, msg)
^^^^^^^^^^^^^

Loggs a message with a tag and the current in-game time to the screen

.. code-block:: lua

    function loglib.log(tag, msg)
        ...
    end

**Arguments:**

.. list-table::
    :widths: 20 20 20 40
    :header-rows: 1

    * - Name
      - Type
      - Default
      - Description
    * - **tag**
      - ``string``
      - ``nil``
      - Tag that will be displayed.
    * - **msg**
      - ``string``
      - ``nil``
      - Message that will be displayed.

**Example:**

.. code-block:: lua

    local loglib = require("loglib")
    loglib.log("Test", "This is a test message")

This would display the text ``<5.345> [Test] This is a test message``, if we assume the current in-game time is ``5.345``.

**Returns:** ``nil``

.. important:: 
    LogLib has to be initialized when using this function.

----







.. _loglib_localfuncs:

Local Functions
---------------

.. note:: 
    Local functions are defined in a local scope and thus can only be used within this program. They mainly server as helper functions for the program itself.

* :ref:`setTitle(title, version) <loglib_localfuncs_setTitle>`

.. _loglib_localfuncs_setTitle:

setTitle(title, version)
^^^^^^^^^^^^^^^^^^^^^^^^

Sets the title displayed at the top of the screen.

.. code-block:: lua

    function loglib.setTitle(title, version)
        ...
    end

**Arguments:**

.. list-table::
    :widths: 20 20 20 40
    :header-rows: 1

    * - Name
      - Type
      - Default
      - Description
    * - **title**
      - ``string``
      - ``nil``
      - Title that will be displayed at the top of the screen.
    * - **version**
      - ``string``
      - ``nil``
      - Version that will be displayed at the top of the screen.

**Returns:** ``nil``

**Example:**

.. code-block:: lua

    local loglib = require("loglib")
    loglib.setTitle("Test PC", "V1.0")

This would display the text ``Test PC V1.0`` at the top of the screen.