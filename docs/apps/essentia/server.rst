.. _essentia_defs_server:

Server
======

The program, that manages requests to controllers and broadcasts them to every specified controller

**Contents:**

* :ref:`Dependencies <essentia_defs_server_deps>`
* :ref:`Configurable Properties <essentia_defs_server_conf>`
* :ref:`Requests <essentia_defs_server_reqs>`
* :ref:`Constants <essentia_defs_server_const>`
* :ref:`Internal Properties <essentia_defs_server_intern>`







.. _essentia_defs_server_deps:

Dependencies
------------

* :ref:`ComLib <comlib>`
* :ref:`DNSLib <dnslib>`
* :ref:`LogLib <loglib>`








.. _essentia_defs_server_conf:

Configurable Properties
-----------------------

.. list-table::
    :header-rows: 1

    * - Name
      - Type
      - Default
    * - :ref:`controllerDomains <essentia_defs_server_conf_controllerDomains>`
      - ``table``
      - ``{}``
    * - :ref:`modemSide <essentia_defs_server_conf_modemSide>`
      - ``string``
      - ``"top"``

.. _essentia_defs_server_conf_controllerDomains:

controllerDomains
^^^^^^^^^^^^^^^^^

A list containing all the domain names of the controllers, which are used to look up the addresses of the controllers.

.. code-block:: lua
    
    local controllerDomains = {}

* **Type:** ``table``
* **Default:** ``{}``

.. important:: 
    The specified domain names have to be registered in the :ref:`DNS Server <dns>`.

----

.. _essentia_defs_server_conf_modemSide:

modemSide
^^^^^^^^^^

The side the wireless modem is connected to the computer.

.. code-block:: lua
    
    local modemSide = "top"

* **Type:** ``string``
* **Default:** ``"top"``

----








.. _essentia_defs_server_reqs:

Requests
--------

* :ref:`FLOW <essentia_defs_server_reqs_FLOW>`
* :ref:`PROBE <essentia_defs_server_reqs_PROBE>`

.. _essentia_defs_server_reqs_FLOW:

FLOW
^^^^

Release 5 essentia from the specified aspect. Fails if aspect is not serverd by controller or amount of essentia of specified aspect is less than 5.

.. note:: 
    The server only broadcasts this request to the controllers specified with :ref:`controllerDomains <essentia_defs_server_conf_controllerDomains>`.
    The controllers actually handle the requests.

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

.. _essentia_defs_server_reqs_PROBE:

PROBE
^^^^^

Probe the amount of specified aspect in jar. Fails if aspect is not serverd by controller.

.. note:: 
    The server only broadcasts this request to the controllers specified with :ref:`controllerDomains <essentia_defs_server_conf_controllerDomains>`.
    The controllers actually handle the requests.

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








.. _essentia_defs_server_const:

Constants
---------

.. list-table::
    :header-rows: 1

    * - Name
      - Type
      - Value
    * - :ref:`title <essentia_defs_server_const_title>`
      - ``string``
      - ``"Essentia Server"``
    * - :ref:`version <essentia_defs_server_const_version>`
      - ``string``
      - ``"v1.0"``

.. _essentia_defs_server_const_title:

title
^^^^^

The title of this program.

.. code-block:: lua
    
    local title = "Essentia Server"

* **Type:** ``string``
* **Default:** ``"Essentia Server"``

----

.. _essentia_defs_server_const_version:

version
^^^^^^^

The version of this program.

.. code-block:: lua
    
    local version = "v1.0"

* **Type:** ``string``
* **Default:** ``"v1.0"``

----








.. _essentia_defs_server_intern:

Internal Properties
-------------------

.. list-table::
    :header-rows: 1

    * - Name
      - Type
      - Default
    * - :ref:`controllerAddresses <essentia_defs_server_intern_controllerAddresses>`
      - ``table``
      - ``{}``
    * - :ref:`sModem <essentia_defs_server_intern_sModem>`
      - ``sModem``
      - ``nil``

.. _essentia_defs_server_intern_controllerAddresses:

controllerAddresses
^^^^^^^^^^^^^^^^^^^

A list containing the resolved addresses of the controllers specified in :ref:`controllerDomains <essentia_defs_server_conf_controllerDomains>`.

.. code-block:: lua
    
    local controllerAddresses = {}

* **Type:** ``table``
* **Default:** ``{}``

----

.. _essentia_defs_server_intern_sModem:

sModem
^^^^^^

An instance of a secure modem object

.. code-block:: lua
    
    local nbtPeripherals = {}

* **Type:** ``sModem``
* **Default:** ``nil``