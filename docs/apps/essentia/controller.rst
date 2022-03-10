.. _essentia_defs_controller:

Controller
==========

The program, that manages controlling the essentia valves and reading amount of aspects stored in jars

**Contents:**

* :ref:`Dependencies <essentia_defs_controller_deps>`
* :ref:`Configurable Properties <essentia_defs_controller_conf>`
* :ref:`Requests <essentia_defs_controller_reqs>`
* :ref:`Constants <essentia_defs_controller_const>`
* :ref:`Internal Properties <essentia_defs_controller_intern>`
* :ref:`Local Functions <essentia_defs_controller_localfuncs>`








.. _essentia_defs_controller_deps:

Dependencies
------------

* :ref:`ComLib <comlib>`
* :ref:`LogLib <loglib>`








.. _essentia_defs_controller_conf:

Configurable Properties
-----------------------

.. list-table::
    :header-rows: 1

    * - Name
      - Type
      - Default
    * - :ref:`servedAspects <essentia_defs_controller_conf_servedAspects>`
      - ``table``
      - ``{}``
    * - :ref:`nbtPeripheralTags <essentia_defs_controller_conf_nbtPeripheralTags>`
      - ``table``
      - ``{}``
    * - :ref:`outputSide <essentia_defs_controller_conf_outputSide>`
      - ``string``
      - ``"back"``
    * - :ref:`modemSide <essentia_defs_controller_conf_modemSide>`
      - ``string``
      - ``"top"``

.. _essentia_defs_controller_conf_servedAspects:

servedAspects
^^^^^^^^^^^^^

A list containing the names of all aspects this controller serves. The order of aspects determines the local ID for each aspect.

.. code-block:: lua
    
    local servedAspects = {}

* **Type:** ``table``
* **Default:** ``{}``

.. warning::
   Please make sure, that the order of the aspects matches the order of the color channels used in the bundled cable. To see the order of the colors, consult the table at the bottom of `this page <https://computercraft.info/wiki/Colors_(API)>`_\ .

----

.. _essentia_defs_controller_conf_nbtPeripheralTags:

nbtPeripheralTags
^^^^^^^^^^^^^^^^^

A list containing the peripheral names (e.g. ``nbt_observer_0``) for the NBT observers. The order of tags corresponds to the local ID.

.. code-block:: lua
    
    local nbtPeripheralTags = {}

* **Type:** ``table``
* **Default:** ``{}``

.. warning::
   Please make sure, that the order of the peripheral names and the order of aspects in :ref:`servedAspects <essentia_defs_controller_conf_servedAspects>` match.

----

.. _essentia_defs_controller_conf_outputSide:

outputSide
^^^^^^^^^^

The side the bundled cable is connected to the computer.

.. code-block:: lua
    
    local outputSide = "back"

* **Type:** ``string``
* **Default:** ``"back"``

----

.. _essentia_defs_controller_conf_modemSide:

modemSide
^^^^^^^^^^

The side the wireless modem is connected to the computer.

.. code-block:: lua
    
    local modemSide = "top"

* **Type:** ``string``
* **Default:** ``"top"``

----








.. _essentia_defs_controller_reqs:

Requests
--------

* :ref:`FLOW <essentia_defs_controller_reqs_FLOW>`
* :ref:`PROBE <essentia_defs_controller_reqs_PROBE>`

.. _essentia_defs_controller_reqs_FLOW:

FLOW
^^^^

Release 5 essentia from the specified aspect. Fails if aspect is not serverd by controller or amount of essentia of specified aspect is less than 5.

.. code-block:: lua

    {head = "FLOW", contents = {aspect = ""}}

**request Contents:**

.. list-table::
    :widths: 20 20 20 40
    :header-rows: 1

    * - Name
      - Type
      - Default
      - Description
    * - **aspect**
      - ``string``
      - ``nil``
      - Aspect of which 5 essentia should be released.

**Response contents:** ``nil``

----

.. _essentia_defs_controller_reqs_PROBE:

PROBE
^^^^^

Probe the amount of specified aspect in jar. Fails if aspect is not serverd by controller.

.. code-block:: lua

    {head = "PROBE", contents = {aspect = ""}}

**Request Contents:**

.. list-table::
    :widths: 20 20 20 40
    :header-rows: 1

    * - Name
      - Type
      - Default
      - Description
    * - **aspect**
      - ``string``
      - ``nil``
      - Aspect of which the amount should be probed.

**Response contents:**

.. list-table::
    :widths: 20 20 60
    :header-rows: 1

    * - Name
      - Type
      - Description
    * - **aspect**
      - ``string``
      - Aspect in probed jar.
    * - **amount**
      - ``number``
      - Amount of stored essentia in probed jar.

.. warning:: 
  If ``aspect`` in response contents doesn't match with ``aspect`` in request contents, then the order of :ref:`nbtPeripheralTags <essentia_defs_controller_conf_nbtperipheraltags>` is most likely faulty.

----







.. _essentia_defs_controller_const:

Constants
---------

.. list-table::
    :header-rows: 1

    * - Name
      - Type
      - Value
    * - :ref:`title <essentia_defs_controller_const_title>`
      - ``string``
      - ``"Essentia Controller"``
    * - :ref:`version <essentia_defs_controller_const_version>`
      - ``string``
      - ``"v1.0"``

.. _essentia_defs_controller_const_title:

title
^^^^^

The title of this program.

.. code-block:: lua
    
    local title = "Essentia Controller"

* **Type:** ``string``
* **Default:** ``"Essentia Controller"``

----

.. _essentia_defs_controller_const_version:

version
^^^^^^^

The version of this program.

.. code-block:: lua
    
    local version = "v1.0"

* **Type:** ``string``
* **Default:** ``"v1.0"``

----








.. _essentia_defs_controller_intern:

Internal Properties
-------------------

.. list-table::
    :header-rows: 1

    * - Name
      - Type
      - Default
    * - :ref:`nbtPeripherals <essentia_defs_controller_intern_nbtPeripherals>`
      - ``table``
      - ``{}``
    * - :ref:`sModem <essentia_defs_controller_intern_sModem>`
      - ``sModem``
      - ``nil``

.. _essentia_defs_controller_intern_nbtPeripherals:

nbtPeripherals
^^^^^^^^^^^^^^

A list containing the wrapped nbt observer peripherals.

.. code-block:: lua
    
    local nbtPeripherals = {}

* **Type:** ``table``
* **Default:** ``{}``

----

.. _essentia_defs_controller_intern_sModem:

sModem
^^^^^^

An instance of a secure modem object

.. code-block:: lua
    
    local sModem = nil

* **Type:** ``sModem``
* **Default:** ``nil``

----








.. _essentia_defs_controller_localfuncs:

Local Functions
---------------

.. note:: 
    Local functions are defined in a local scope and thus can only be used within this program. They mainly server as helper functions for the program itself.

* :ref:`getLocalID(aspect) <essentia_defs_controller_localfuncs_getLocalID>`
* :ref:`sendPulse(id) <essentia_defs_controller_localfuncs_sendPulse>`

.. _essentia_defs_controller_localfuncs_getLocalID:

getLocalID(aspect)
^^^^^^^^^^^^^^^^^^

Converts aspect name to local ID using :ref:`servedAspects <essentia_defs_controller_conf_servedAspects>`\ .

.. code-block:: lua

    local funtion getLocalID(aspect)
        ...
        return localID
    end

**Arguments:**

.. list-table::
    :widths: 20 20 20 40
    :header-rows: 1

    * - Name
      - Type
      - Default
      - Description
    * - **aspect**
      - ``string``
      - ``nil``
      - Aspect to convert to local ID.

**Returns:** 

.. list-table::
    :widths: 20 80
    :header-rows: 1

    * - Type
      - Description
    * - ``number``
      - Local ID of **aspect** or 0 if **aspect** is not served.

**Example:**

.. code-block:: lua

  local servedAspects = {"terra", "aqua", "aer", "ignis", "ordo"}
  local localID = getLocalID("aer")

In this case, ``localID`` would equal to ``3``, since ``aer`` is the third element in the table

.. note:: 
  The table ``servedAspects`` would normally be set as a :ref:`configurable property <essentia_defs_controller_conf_servedaspects>`

----

.. _essentia_defs_controller_localfuncs_sendPulse:

sendPulse(id)
^^^^^^^^^^^^^

Sends a redstone pulse on the specified channel through the bundled wire at :ref:`outputSide <essentia_defs_controller_conf_outputSide>`\ .

.. code-block:: lua

    local funtion snedPulse(id)
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
      - ``number``
      - ``nil``
      - Local ID of aspect / Channel to send a pulse to.


**Returns:** ``nil``

**Example:**

.. code-block:: lua

  sendPulse(4)

This would send a redstone pulse on the :ref:`outputSide <essentia_defs_controller_conf_outputside>` on the color channel corresponding to the number ``2 ^ (id - 1)``,
in this case ``8``, which corresponds to the color ``lightBlue`` as seen `here <https://computercraft.info/wiki/Colors_(API)>`_\ . Thus this command would send a pulse on the lightBlue channel.