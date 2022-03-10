.. _uilib_style:

Style
=====

This is a class, that contains and handles styles for UI elements for different states.

**Contents:**

* :ref:`States <uilib_style_states>`
* :ref:`Properties <uilib_style_props>`
* :ref:`Functions <uilib_style_funcs>`








.. _uilib_style_states:

States
------

The possible states for UI element styles. The flag **pressed** refers to the flag of the UI element, that is raised when it gets clicked.
The flag **disabled** refers to the flag of the UI element, that can be raised to disable said element.

.. list-table:: 
    :widths: 1 1 1
    :header-rows: 1

    * - State
      - pressed
      - disabled
    * - Normal / Default
      - ``false``
      - ``false``
    * - Pressed
      - ``true``
      - ``false``
    * - disabled
      - ``true`` or ``false``
      - ``true``








.. _uilib_style_props:

Properties
----------

.. list-table::
    :header-rows: 1

    * - Name
      - Type
      - Default
    * - :ref:`normalFG <uilib_style_props_normalFG>`
      - ``number``
      - ``colors.white``
    * - :ref:`normalBG <uilib_style_props_normalBG>`
      - ``number``
      - ``colors.gray``
    * - :ref:`pressedFG <uilib_style_props_pressedFG>`
      - ``number``
      - ``colors.white``
    * - :ref:`pressedBG <uilib_style_props_pressedBG>`
      - ``number``
      - ``colors.lime``
    * - :ref:`disabledFG <uilib_style_props_disabledFG>`
      - ``number``
      - ``colors.gray``
    * - :ref:`disabledBG <uilib_style_props_disabledBG>`
      - ``number``
      - ``colors.lightGray``

.. _uilib_style_props_normalFG:

normalFG
^^^^^^^^

Foreground color in default state.

.. code-block:: lua

    uilib.Style.normalFG = colors.white

* **Type:** ``number``
* **Default:** ``colors.white``

.. note::
   It is recommended to set this property with the `Colors(API) <https://computercraft.info/wiki/Colors_(API)>`_\ .
   If you choose to set this property with numeric values directly, please consult the table at the bottom of `this page <https://computercraft.info/wiki/Colors_(API)>`_ for the correct values.

----

.. _uilib_style_props_normalBG:

normalBG
^^^^^^^^

Background color in default state.

.. code-block:: lua

    uilib.Style.normalBG = colors.gray

* **Type:** ``number``
* **Default:** ``colors.gray``

.. note::
   It is recommended to set this property with the `Colors(API) <https://computercraft.info/wiki/Colors_(API)>`_\ .
   If you choose to set this property with numeric values directly, please consult the table at the bottom of `this page <https://computercraft.info/wiki/Colors_(API)>`_ for the correct values.

----

.. _uilib_style_props_pressedFG:

pressedFG
^^^^^^^^^

Foreground color in pressed state.

.. code-block:: lua

    uilib.Style.pressedFG = colors.white

* **Type:** ``number``
* **Default:** ``colors.white``

.. note::
   It is recommended to set this property with the `Colors(API) <https://computercraft.info/wiki/Colors_(API)>`_\ .
   If you choose to set this property with numeric values directly, please consult the table at the bottom of `this page <https://computercraft.info/wiki/Colors_(API)>`_ for the correct values.

----

.. _uilib_style_props_pressedBG:

pressedBG
^^^^^^^^^

Background color in pressed state.

.. code-block:: lua

    uilib.Style.pressedBG = colors.lime

* **Type:** ``number``
* **Default:** ``colors.lime``

.. note::
   It is recommended to set this property with the `Colors(API) <https://computercraft.info/wiki/Colors_(API)>`_\ .
   If you choose to set this property with numeric values directly, please consult the table at the bottom of `this page <https://computercraft.info/wiki/Colors_(API)>`_ for the correct values.

----

.. _uilib_style_props_disabledFG:

disabledFG
^^^^^^^^^^

Foreground color in disabled state.

.. code-block:: lua

    uilib.Style.disabledFG = colors.gray

* **Type:** ``number``
* **Default:** ``colors.gray``

.. note::
   It is recommended to set this property with the `Colors(API) <https://computercraft.info/wiki/Colors_(API)>`_\ .
   If you choose to set this property with numeric values directly, please consult the table at the bottom of `this page <https://computercraft.info/wiki/Colors_(API)>`_ for the correct values.

----

.. _uilib_style_props_disabledBG:

disabledBG
^^^^^^^^^^

Background color in disabled state.

.. code-block:: lua

    uilib.Style.disabledBG = colors.lightGray

* **Type:** ``number``
* **Default:** ``colors.lightGray``

.. note::
   It is recommended to set this property with the `Colors(API) <https://computercraft.info/wiki/Colors_(API)>`_\ .
   If you choose to set this property with numeric values directly, please consult the table at the bottom of `this page <https://computercraft.info/wiki/Colors_(API)>`_ for the correct values.

----








.. _uilib_style_funcs:

Functions
---------

* :ref:`new() <uilib_style_funcs_new>`
* :ref:`getColors() <uilib_style_funcs_getColors>`

.. _uilib_style_funcs_new:

new()
^^^^^

Creates a new instance of :ref:`Style <uilib_style>` and returns it.

.. code-block:: lua

    function uilib.Style:new(normalFG, normalBG, pressedFG, pressedBG, disabledFG, disabledBG)
        ...
        return style
    end

**Arguments:**

.. list-table:: 
    :widths: 20 20 20 40
    :header-rows: 1

    * - Name
      - Type
      - Default
      - Description
    * - **normalFG**
      - ``number``
      - ``colors.white``
      - Foreground color for default state.
    * - **normalBG**
      - ``number``
      - ``colors.gray``
      - Background color for default state.
    * - **pressedFG**
      - ``number``
      - ``colors.white``
      - Foreground color for pressed state.
    * - **pressedBG**
      - ``number``
      - ``colors.lime``
      - Background color for pressed state.
    * - **disabledFG**
      - ``number``
      - ``colors.gray``
      - Foreground color for disabled state.
    * - **disabledBG**
      - ``number``
      - ``colors.lightGray``
      - Background color for disabled state.

**Returns:**

.. list-table::
    :widths: 20 80
    :header-rows: 1

    * - Type
      - Description
    * - :ref:`Style <uilib_style>`
      - Instance of :ref:`Style <uilib_style>` with specified properties.

**Example:**

.. code-block:: lua

    local uilib = require("uilib")
    local style = uilib.Style:new(colors.red. colors.lightGray)

This would create an instance of :ref:`Style <uilib_style>` with ``colors.red`` as :ref:`normalFG <uilib_style_props_normalFG>` and ``colors.lightGray`` as :ref:`normalBG <uilib_style_props_normalBG>`.
All other properties would be set to their respective default value.

----

.. _uilib_style_funcs_getColors:

getColors()
^^^^^^^^^^^

Returns the foreground and background color for the current state of the UI element.

.. code-block:: lua

    function uilib.Style:getColors(pressed, disabled)
        ...
        return fg, bg
    end

**Arguments:**

.. list-table:: 
    :widths: 20 20 20 40
    :header-rows: 1

    * - Name
      - Type
      - Default
      - Description
    * - **pressed**
      - ``boolean``
      - ``false``
      - Flag if UI element has been clicked.
    * - **disabled**
      - ``boolean``
      - ``false``
      - Flag if UI element has been disabled.

**Returns:**

.. list-table::
    :widths: 20 80
    :header-rows: 1

    * - Type
      - Description
    * - ``number``
      - Foreground color for current state of UI element.
    * - ``number``
      - Background color for current state of UI element.

**Example:**

.. code-block:: lua

    local uilib = require("uilib")
    local style = uilib.Style:new(colors.red. colors.lightGray)
    local fg, bg = style:getColors(false, false)

This would create an instance of :ref:`Style <uilib_style>` with ``colors.red`` as :ref:`normalFG <uilib_style_props_normalFG>` and ``colors.lightGray`` as :ref:`normalBG <uilib_style_props_normalBG>`.
After that it would get the foregournd and background color for the default state, since ``pressed`` and ``disabled`` are both ``false``.
So ``fg`` and ``bg`` would contain ``colors.red`` and ``colors.lightGray`` respectively.