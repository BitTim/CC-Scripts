.. _uilib_group:

Group
=====

A UI element, that holds multiple other UI elements and draws them together.

**Contents:**

* :ref:`Properties <uilib_group_props>`
* :ref:`Functions <uilib_group_funcs>`








.. _uilib_group_props:

Properties
----------

.. list-table:: 
    :header-rows: 1

    * - Name
      - Type
      - Default
    * - :ref:`normalFG <uilib_group_props_x>`
      - ``number``
      - ``nil``
    * - :ref:`normalBG <uilib_group_props_y>`
      - ``number``
      - ``nil``
    * - :ref:`pressedFG <uilib_group_props_elements>`
      - ``table``
      - ``{}``

.. _uilib_group_props_x:

x
^^^^

X component of the position on the screen.

.. code-block:: lua

    uilib.Group.x = nil

* **Type:** ``number``
* **Default:** ``nil``

----

.. _uilib_group_props_y:

y
^^^^

Y component of the position on the screen.

.. code-block:: lua

    uilib.Group.y = nil

* **Type:** ``number``
* **Default:** ``nil``

----

.. _uilib_group_props_elements:

elements
^^^^^^^^

List of all UI elements included within the group.

.. code-block:: lua

    uilib.Group.elements = {}

* **Type:** ``table``
* **Default:** ``{}``

----

.. _uilib_group_props_visible:

visible
^^^^^^^

Contains information about the group being visible or not.

.. code-block:: lua

    uilib.Group.visible = true

* **Type:** ``boolean``
* **Default:** ``true``

.. note:: 
    Please use :ref:`show() <uilib_group_funcs_show>` to enable visibility and :ref:`hide() <uilib_group_funcs_hide>` to disable visibility of the group.

----








.. _uilib_group_funcs:

Functions
---------

* :ref:`new() <uilib_group_funcs_new>`
* :ref:`draw() <uilib_group_funcs_draw>`
* :ref:`add() <uilib_group_funcs_add>`
* :ref:`remove() <uilib_group_funcs_remove>`
* :ref:`get() <uilib_group_funcs_get>`
* :ref:`show() <uilib_group_funcs_show>`
* :ref:`hide() <uilib_group_funcs_hide>`

.. _uilib_group_funcs_new:

new()
^^^^^

Function to create a new instance of :ref:`Group <uilib_group>`.

.. code-block:: lua

    function M.Group:new(x, y, elements)
      ...
      return group
    end

**Arguments:**

.. list-table:: 
    :widths: 20 20 20 40
    :header-rows: 1

    * - Name
      - Type
      - Default
      - Description
    * - **x**
      - ``number``
      - ``nil``
      - X component of position of the group.
    * - **y**
      - ``number``
      - ``nil``
      - Y component of position of the group.
    * - **elements**
      - ``table``
      - ``nil``
      - List of all contained UI elements.

.. important:: 
    The ``elements`` list must contain the elements with a string key attached to them, e.g. ``{label = elementVar}``.

.. important:: 
    When you add a UI element to a group, the ``x`` and ``y`` parameters will become local to the group, which means that the actual position of the UI element would be:
    ``(group.x + element.x - 1, group.y + element.y - 1)``.

**Returns:**

.. list-table::
    :widths: 20 80
    :header-rows: 1

    * - Type
      - Description
    * - :ref:`uilib.Group <uilib_group>`
      - Instance of :ref:`Group <uilib_group>` with specified properties.

**Example:**

.. code-block:: lua

  local uilib = require("uilib")
  local label = uilib.Label("I am a Label!", 4, 5, uilib.Style:new(colors.red, colors.black))
  local group = uilib.Group:new(2, 2, {label = label})

This would create an instance of a :ref:`Group <uilib_group>` and a :ref:`Label <uilib_label>` within the created group.
The Label would be drawn at position ``(5, 6)``.

----

.. _uilib_group_funcs_draw:

draw()
^^^^^^

Function to draw the group.

.. code-block:: lua

  function M.Group:draw()
    ...
  end

**Arguments:** ``nil``

**Returns:** ``nil``

**Example:**

.. code-block:: lua

  local uilib = require("uilib")
  local label = uilib.Label("I am a Label!", 4, 5, uilib.Style:new(colors.red, colors.black))
  local group = uilib.Group:new(2, 2, {label = label})
  
  group:draw()

This would create an instance of a :ref:`Group <uilib_group>` and a :ref:`Label <uilib_label>` within the created group and draw it to the screen.

----

.. _uilib_group_funcs_add:

add()
^^^^^

Function to add a UI element to the group.

.. code-block:: lua

  function M.Group:add(element, id)
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
    * - **element**
      - ``table``
      - ``nil``
      - UI element to add.
    * - **id**
      - ``string``
      - ``nil``
      - ID to refer to the UI element.

.. important:: 
    When you add a UI element to a group, the ``x`` and ``y`` parameters will become local to the group, which means that the actual position of the UI element would be:
    ``(group.x + element.x - 1, group.y + element.y - 1)``.

**Returns:** ``nil``

**Example:**

.. code-block:: lua

  local uilib = require("uilib")
  local label = uilib.Label("I am a Label!", 4, 5, uilib.Style:new(colors.red, colors.black))
  local group = uilib.Group:new(2, 2, {})
  
  group:add(label, "label")

This would create an instance of a :ref:`Group <uilib_group>` and a :ref:`Label <uilib_label>`, which is being added to the group with the ID ``"label2``.

----

.. _uilib_group_funcs_remove:

remove()
^^^^^^^^

Function to remove a UI element from the group.

.. code-block:: lua

  function M.Group:remove(id)
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
    * - **id**
      - ``string``
      - ``nil``
      - ID of the element.

**Returns:** ``nil``

**Example:**

.. code-block:: lua

  local uilib = require("uilib")
  local label = uilib.Label("I am a Label!", 4, 5, uilib.Style:new(colors.red, colors.black))
  local group = uilib.Group:new(2, 2, {label = label})
  
  group:remove("label")

This would create an instance of a :ref:`Group <uilib_group>` and a :ref:`Label <uilib_label>` within the created group.
It would then remove the created label from the group.

----

.. _uilib_group_funcs_get:

get()
^^^^^

Function to get a specific UI element from the group.

.. code-block:: lua

  function M.Group:get(id)
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
    * - **id**
      - ``string``
      - ``nil``
      - ID of the UI element.

**Returns:**

.. list-table::
    :widths: 20 80
    :header-rows: 1

    * - Type
      - Description
    * - ``table``
      - UI element with the specified id in the group.

.. warning::
    This function returns ``-1`` instead of the above, if one of these conditions is met:
  
    * No UI element with the specified ID exists.


**Example:**

.. code-block:: lua

  local uilib = require("uilib")
  local label = uilib.Label("I am a Label!", 4, 5, uilib.Style:new(colors.red, colors.black))
  local group = uilib.Group:new(2, 2, {label = label})
  
  local labelAgain = group:get("label")

This would create an instance of a :ref:`Group <uilib_group>` and a :ref:`Label <uilib_label>` within the created group.
After that it would store the label element with the ID ``"label"`` in ``labelAgain``.

----

.. _uilib_group_funcs_show:

show()
^^^^^^

Function to make the group visible.

.. code-block:: lua

    function uilib.Group:show()
        ...
    end

**Arguments:** ``nil``

**Returns:** ``nil``

**Example:**

.. code-block:: lua

    local uilib = require("uilib")
    local label = uilib.Label("I am a Label!", 4, 5, uilib.Style:new(colors.red, colors.black))
    local group = uilib.Group:new(2, 2, {label = label})

    group:show()

This would create an instance of a :ref:`Group <uilib_group>` and a :ref:`Label <uilib_label>` within the created group and make it visible.

----

.. _uilib_group_funcs_hide:

hide()
^^^^^^

Function to make the group invisible.

.. code-block:: lua

    function uilib.Group:hide()
      ...
    end

**Arguments:** ``nil``

**Returns:** ``nil``

**Example:**

.. code-block:: lua

    local uilib = require("uilib")
    local label = uilib.Label("I am a Label!", 4, 5, uilib.Style:new(colors.red, colors.black))
    local group = uilib.Group:new(2, 2, {label = label})

    group:hide()

This would create an instance of a :ref:`Group <uilib_group>` and a :ref:`Label <uilib_label>` within the created group and make it invisible.