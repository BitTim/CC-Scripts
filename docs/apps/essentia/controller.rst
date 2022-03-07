.. _essentia_docs_controller:

Controller
==========

The program, that manages controlling the essentia valves and reading amount of aspects stored in jars








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

.. _essentia_docs_controller_propint_nbtPeripherals:

nbtPeripherals
^^^^^^^^^^^^^^

A list containing the wrapped nbt observer peripherals.

.. code-block:: lua
    
    local nbtPeripherals = {}

* **Type:** ``table``
* **Default:** ``{}``

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