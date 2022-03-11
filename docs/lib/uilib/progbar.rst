.. _uilib_progbar:

ProgressBar
===========

A UI element that shows a bar, that can be filled to different amounts in multiple orientations.

**Contents:**

* :ref:`Properties <uilib_progbar_props>`
* :ref:`Functions <uilib_progbar_funcs>`








.. _uilib_progbar_props:

Properties
----------

.. list-table::
    :header-rows: 1

    * - Name
      - Type
      - Default
    * - :ref:`minVal <uilib_progbar_props_minVal>`
      - ``number``
      - ``nil``
    * - :ref:`maxVal <uilib_progbar_props_maxVal>`
      - ``number``
      - ``nil``
    * - :ref:`val <uilib_progbar_props_val>`
      - ``number``
      - ``nil``
    * - :ref:`x <uilib_progbar_props_x>`
      - ``number``
      - ``nil``
    * - :ref:`y <uilib_progbar_props_y>`
      - ``number``
      - ``nil``
    * - :ref:`w <uilib_progbar_props_w>`
      - ``number``
      - ``nil``
    * - :ref:`h <uilib_progbar_props_h>`
      - ``number``
      - ``nil``
    * - :ref:`vertical <uilib_progbar_props_vertical>`
      - ``boolean``
      - ``false``
    * - :ref:`inverted <uilib_progbar_props_inverted>`
      - ``boolean``
      - ``false``
    * - :ref:`style <uilib_progbar_props_style>`
      - :ref:`uilib.Style <uilib_style>`
      - :ref:`Default Style <uilib_style_funcs_new>`
    * - :ref:`visible <uilib_progbar_props_visible>`
      - ``boolean``
      - ``true``

.. _uilib_progbar_props_minVal:

minVal
^^^^^^

Smallest value the progress bar can display.

.. code-block:: lua

    uilib.ProgressBar.minVal = nil

* **Type:** ``number``
* **Default:** ``nil``

----

.. _uilib_progbar_props_maxVal:

maxVal
^^^^^^

Biggest value the progress bar can display.

.. code-block:: lua

    uilib.ProgressBar.maxVal = nil

* **Type:** ``number``
* **Default:** ``nil``

----

.. _uilib_progbar_props_val:

val
^^^

Current value the progress bar should display.

.. code-block:: lua

    uilib.ProgressBar.val = nil

* **Type:** ``number``
* **Default:** ``nil``

----

.. _uilib_progbar_props_x:

x
^^^^

X component of the position on the screen.

.. code-block:: lua

    uilib.ProgressBar.x = nil

* **Type:** ``number``
* **Default:** ``nil``

----

.. _uilib_progbar_props_y:

y
^^^^

Y component of the position on the screen.

.. code-block:: lua

    uilib.ProgressBar.y = nil

* **Type:** ``number``
* **Default:** ``nil``

----

.. _uilib_progbar_props_w:

w
^^^^

Width of the progress bar.

.. code-block:: lua

    uilib.ProgressBar.w = nil

* **Type:** ``number``
* **Default:** ``nil``

----

.. _uilib_progbar_props_h:

h
^^^^

Height of the progress bar.

.. code-block:: lua

    uilib.ProgressBar.h = nil

* **Type:** ``number``
* **Default:** ``nil``

----

.. _uilib_progbar_props_vertical:

vertical
^^^^^^^^

Enables vertical mode for the progress bar.

.. code-block:: lua

    uilib.ProgressBar.vertical = false

* **Type:** ``boolean``
* **Default:** ``false``

----

.. _uilib_progbar_props_inverted:

inverted
^^^^^^^^

Enables inverted mode for the progress bar.

.. code-block:: lua

    uilib.ProgressBar.inverted = false

* **Type:** ``boolean``
* **Default:** ``false``

----

.. _uilib_progbar_props_style:

style
^^^^^

Style of the progress bar.

.. code-block:: lua

    uilib.ProgressBar.style = uilib.Style:new()

* **Type:** :ref:`uilib.Style <uilib_style>`
* **Default:** :ref:`Default Style <uilib_style_funcs_new>`

----

.. _uilib_progbar_props_visible:

visible
^^^^^^^

Contains information about the progress bar being visible or not.

.. code-block:: lua

    uilib.ProgressBar.visible = true

* **Type:** ``boolean``
* **Default:** ``true``

.. note:: 
    Please use :ref:`show() <uilib_progbar_funcs_show>` to enable visibility and :ref:`hide() <uilib_progbar_funcs_hide>` to disable visibility of the progress bar.

----








.. _uilib_progbar_funcs:

Functions
---------

* :ref:`new() <uilib_progbar_funcs_new>`
* :ref:`draw() <uilib_progbar_funcs_draw>`
* :ref:`show() <uilib_progbar_funcs_show>`
* :ref:`hide() <uilib_progbar_funcs_hide>`

.. _uilib_progbar_funcs_new:

new()
^^^^^

Function to create a new instance of :ref:`ProgressBar <uilib_progbar>`.

.. code-block:: lua

    function M.ProgressBar:new(minVal, maxVal, val, x, y, w, h, vertical, inverted, style)
      ...
      return prog
    end

**Arguments:**

.. list-table:: 
    :widths: 20 20 20 40
    :header-rows: 1

    * - Name
      - Type
      - Default
      - Description
    * - **minVal**
      - ``number``
      - ``nil``
      - Smallest value the progress bar can display.
    * - **maxVal**
      - ``number``
      - ``nil``
      - Biggest value the progress bar can display.
    * - **val**
      - ``number``
      - ``nil``
      - Current value the progress bar should display.
    * - **x**
      - ``number``
      - ``nil``
      - X component of position of the progress bar.
    * - **y**
      - ``number``
      - ``nil``
      - Y component of position of the progress bar.
    * - **w**
      - ``number``
      - ``nil``
      - Width of the progress bar.
    * - **h**
      - ``number``
      - ``nil``
      - Height of the progress bar.
    * - **vertical**
      - ``boolean``
      - ``false``
      - Enables vertical mode for the progres bar.
    * - **inverted**
      - ``boolean``
      - ``false``
      - Enables inverted mode for the progres bar.
    * - **style**
      - :ref:`uilib.Style <uilib_style>`
      - :ref:`Default Style <uilib_style_funcs_new>`
      - Style of the progress bar.

.. note:: 
    Progress bars can only use the :ref:`default state <uilib_style_states>`.

**Returns:**

.. list-table::
    :widths: 20 80
    :header-rows: 1

    * - Type
      - Description
    * - :ref:`uilib.ProgressBar <uilib_progbar>`
      - Instance of :ref:`ProgressBar <uilib_progbar>` with specified properties.

**Example:**

.. code-block:: lua

  local uilib = require("uilib")
  local prog = uilib.ProgressBar:new(0, 100, 35, 2, 2, 10, 1, false, false, uilib.Style:new())

This would create an instance of :ref:`ProgressBar <uilib_progbar>` with possible values between ``0`` and ``100`` and an initial value of ``35``.
The progress bar would be displayed at the position ``(2, 2)`` and would be ``10 x 1`` pixels in size. It would be in horizontal mode, since ``vertical`` is set to ``false``.
The style of the progress bar will be the default style.

----

.. _uilib_progbar_funcs_draw:

draw()
^^^^^^

Function to draw the progress bar.

.. code-block:: lua

  function M.ProgressBar:draw()
    ...
  end

**Arguments:** ``nil``

**Returns:** ``nil``

**Example:**

.. code-block:: lua

  local uilib = require("uilib")
  local prog = uilib.ProgressBar:new(0, 100, 35, 2, 2, 10, 1, false, false, uilib.Style:new())
  prog:draw()

This would create an instance of :ref:`ProgressBar <uilib_progbar>` and draw it to the screen.

----

.. _uilib_progbar_funcs_show:

show()
^^^^^^

Function to make the progress bar visible.

.. code-block:: lua

    function uilib.ProgressBar:show()
        ...
    end

**Arguments:** ``nil``

**Returns:** ``nil``

**Example:**

.. code-block:: lua

    local uilib = require("uilib")
    local prog = uilib.ProgressBar:new(0, 100, 35, 2, 2, 10, 1, false, false, uilib.Style:new())
    prog:show()

This would create an instance of :ref:`ProgressBar <uilib_progbar>` and make it visible.

----

.. _uilib_progbar_funcs_hide:

hide()
^^^^^^

Function to make the progress bar invisible.

.. code-block:: lua

    function uilib.ProgressBar:hide()
      ...
    end

**Arguments:** ``nil``

**Returns:** ``nil``

**Example:**

.. code-block:: lua

    local uilib = require("uilib")
    local prog = uilib.ProgressBar:new(0, 100, 35, 2, 2, 10, 1, false, false, uilib.Style:new())
    prog:hide()

This would create an instance of :ref:`ProgressBar <uilib_progbar>` and make it invisible.