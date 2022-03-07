.. _essentia_docs_controller:

Controller
==========

The program, that manages controlling the essentia valves and reading amount of aspects stored in jars

**Contents:**

* :ref:`Dependencies <essentia_docs_controller_deps>`
* :ref:`Properties - Configurable <essentia_docs_controller_propconf>`
* :ref:`Properties - Internal <essentia_docs_controller_propint>`
* :ref:`Packet Headers <essentia_docs_controller_packhead>`
* :ref:`Functions <essentia_docs_controller_funcs>`








.. _essentia_docs_controller_deps:

Dependencies
------------

* :ref:`ComLib <comlib>`








.. _essentia_docs_controller_propconf:

Properties - Configurable
-------------------------

.. list-table::
    :header-rows: 1

    * - Name
      - Type
      - Default
    * - :ref:`servedAspects <essentia_docs_controller_propconf_servedAspects>`
      - ``table``
      - ``{}``
    * - :ref:`nbtPeripheralTags <essentia_docs_controller_propconf_nbtPeripheralTags>`
      - ``table``
      - ``{}``
    * - :ref:`outputSide <essentia_docs_controller_propconf_outputSide>`
      - ``string``
      - ``"back"``
    * - :ref:`modemSide <essentia_docs_controller_propconf_modemSide>`
      - ``string``
      - ``"top"``

.. _essentia_docs_controller_propconf_servedAspects:

servedAspects
^^^^^^^^^^^^^

A list containing the names of all aspects this controller servers. The order of aspects determines the local ID for each aspect.

.. code-block:: lua
    
    local servedAspects = {}

* **Type:** ``table``
* **Default:** ``{}``

----

.. _essentia_docs_controller_propconf_nbtPeripheralTags:

nbtPeripheralTags
^^^^^^^^^^^^^^^^^

A list containing the peripheral names for the NBT observers. The order of tags corresponds to the local ID, make sure the orders match.

.. code-block:: lua
    
    local nbtPeripheralTags = {}

* **Type:** ``table``
* **Default:** ``{}``

----

.. _essentia_docs_controller_propconf_outputSide:

outputSide
^^^^^^^^^^

The side the bundled cable is connected to the computer.

.. code-block:: lua
    
    local outputSide = "back"

* **Type:** ``string``
* **Default:** ``"back"``

----

.. _essentia_docs_controller_propconf_modemSide:

modemSide
^^^^^^^^^^

The side the wireless modem is connected to the computer.

.. code-block:: lua
    
    local outputSide = "top"

* **Type:** ``string``
* **Default:** ``"top"``

----








.. _essentia_docs_controller_propint:

Properties - Internal
---------------------

.. list-table::
    :header-rows: 1

    * - Name
      - Type
      - Default
    * - :ref:`nbtPeripherals <essentia_docs_controller_propint_nbtPeripherals>`
      - ``table``
      - ``{}``
    * - :ref:`sModem <essentia_docs_controller_propint_sModem>`
      - ``sModem``
      - ``nil``

.. _essentia_docs_controller_propint_nbtPeripherals:

nbtPeripherals
^^^^^^^^^^^^^^

A list containing the wrapped nbt observer peripherals.

.. code-block:: lua
    
    local nbtPeripherals = {}

* **Type:** ``table``
* **Default:** ``{}``

----

.. _essentia_docs_controller_propint_sModem:

sModem
^^^^^^

An instance of a secure modem object

.. code-block:: lua
    
    local nbtPeripherals = {}

* **Type:** ``sModem``
* **Default:** ``nil``

----








.. _essentia_docs_controller_packhead:

Packet Headers
--------------

* :ref:`FLOW <essentia_docs_controller_packhead_FLOW>`
* :ref:`PROBE <essentia_docs_controller_packhead_PROBE>`

.. _essentia_docs_controller_packhead_FLOW:

FLOW
^^^^

Release 5 essentia from the specified aspect. Fails if aspect is not serverd by controller or amount of essentia of specified aspect is less than 5.

.. code-block:: lua

    {head = "FLOW", contents = {aspect = ""}}

**Contents:**

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

.. _essentia_docs_controller_packhead_PROBE:

PROBE
^^^^^

Probe the amount of specified aspect in jar. Fails if aspect is not serverd by controller.

.. code-block:: lua

    {head = "FLOW", contents = {aspect = ""}}

**Contents:**

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

**Response contents:**

.. list-table::
    :widths: 20 20 20 40
    :header-rows: 1

    * - Name
      - Type
      - Default
      - Description
    * - **amount**
      - ``number``
      - ``0``
      - Amount of stored essentia of specified aspect.

----








.. _essentia_docs_controller_funcs:

Functions
---------

* :ref:`getLocalID(aspect) <essentia_docs_controller_funcs_getLocalID>`
* :ref:`sendPulse(id) <essentia_docs_controller_funcs_sendPulse>`

.. _essentia_docs_controller_funcs_getLocalID:

getLocalID(aspect)
^^^^^^^^^^^^^^^^^^

Converts aspect name to local ID using :ref:`servedAspects <essentia_docs_controller_propconf_servedAspects>`\ .

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
  The table ``servedAspects`` would normally be set as a :ref:`configurable property <essentia_docs_controller_propconf_servedaspects>`

----

.. _essentia_docs_controller_funcs_sendPulse:

sendPulse(id)
^^^^^^^^^^^^^

Sends a redstone pulse on the specified channel through the bundled wire at :ref:`outputSide <essentia_docs_controller_propconf_outputSide>`\ .

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

This would send a redstone pulse on the :ref:`outputSide <essentia_docs_controller_propconf_outputside>` on the color channel corresponding to the number ``2 ^ (id - 1)``,
in this case ``8``, which corresponds to the color ``lightBlue`` as seen `here <https://computercraft.info/wiki/Colors_(API)>`_\ . Thus this command would send a pulse on the lightBlue channel.