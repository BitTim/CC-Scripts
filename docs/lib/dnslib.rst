.. _dnslib:

DNSLib
======

A library for various DNS operations

.. important:: 
    To use this library, a functioning :ref:`DNS Server <dns>` is required.

**Contents:**

* :ref:`Dependencies <dnslib_deps>`
* :ref:`Properties <dnslib_prop>`
* :ref:`Functions <dnslib_funcs>`








.. _dnslib_deps:

Dependencies
------------

* :ref:`ComLib <comlib>`








.. _dnslib_prop:

Properties
----------

.. list-table::
    :header-rows: 1

    * - Name
      - Type
      - Default
    * - :ref:`dnsAddress <dnslib_prop_dnsAddress>`
      - ``string``
      - ``""``

.. _dnslib_prop_dnsAddress:

dnsAddress
^^^^^^^^^^

The address of the DNS Server.

.. code-block:: lua
    
    dnslib.dnsAddress = ""

* **Type:** ``string``
* **Default:** ``""``

.. note::
   This property is set using :ref:`init(address) <dnslib_funcs_init>`

----








.. _dnslib_funcs:

Functions
---------

* :ref:`init() <dnslib_funcs_init>`
* :ref:`lookup(domain) <dnslib_funcs_lookup>`
* :ref:`lookupMultiple(domains) <dnslib_funcs_lookupMultiple>`

.. _dnslib_funcs_init:

init(address)
^^^^^^^^^^^^^

Initializes DNSLib and sets :ref:`dnsAddress <dnslib_prop_dnsAddress>` to an address read from the ``/.dnsAddress`` file. If the file does not exist the function will return ``-1``.

.. code-block:: lua

    function dnslib.init()
        ...
        return success
    end

**Arguments:** ``nil``

**Returns:**

.. list-table::
    :widths: 20 80
    :header-rows: 1

    * - Type
      - Description
    * - ``boolean``
      - Initialization success.

.. warning::
    This function returns ``-1`` instead of the above, if one of these conditions is met:

    * ``/.dnsAddress`` file does not exist.
    * Address read from ``/.dnsAddress`` is empty or ``nil``.

**Example:**

.. code-block:: lua

    local dnslib = require("dnslib")
    dnslib.init()

This would initialize DNSLib and set :ref:`dnsAddress <dnslib_prop_dnsAddress>` to an addres found in ``/.dnsAddress``.

----

.. _dnslib_funcs_lookup:

lookup(domain)
^^^^^^^^^^^^^^

Looks up the specified domain and returns the address of the registered server.

.. code-block:: lua

    function dnslib.lookup(domain)
        ...
        return address
    end

**Arguments:**

.. list-table:: 
    :widths: 20 20 20 40
    :header-rows: 1

    * - Name
      - Type
      - Default
      - Description
    * - **domain**
      - ``string``
      - ``nil``
      - Domain to look up.

**Returns:**

.. list-table::
    :widths: 20 80
    :header-rows: 1

    * - Type
      - Description
    * - ``string``
      - Address of the corresponding registered server.

.. warning::
    This function returns ``-1`` instead of the above, if one of these conditions is met:

    * :ref:`sendRequest() <comlib_funcs_sendRequest>` has errored (Has returned ``-1`` as well).

**Example:**

.. code-block:: lua

    local dnslib = require("dnslib")
    local address = dnslib.lookup("test.com")

Here ``address`` would contain the address the :ref:`DNS Server <dns>` knows for ``"test.com"``

----

.. _dnslib_funcs_lookupMultiple:

lookupMultiple(domains)
^^^^^^^^^^^^^^^^^^^^^^^

Looks up the multiple domains and returns the addresses of the registered servers.

.. note:: 
  This function calls :ref:`lookup() <dnslib_funcs_lookup>` for each domain.

.. code-block:: lua

    function dnslib.lookupMultiple(domains)
        ...
        return addresses
    end

**Arguments:**

.. list-table:: 
    :widths: 20 20 20 40
    :header-rows: 1

    * - Name
      - Type
      - Default
      - Description
    * - **domains**
      - ``table``
      - ``nil``
      - Domains to look up.

**Returns:**

.. list-table::
    :widths: 20 80
    :header-rows: 1

    * - Type
      - Description
    * - ``table``
      - Addresses of the corresponding registered servers.

.. warning::
    This function returns ``-1`` instead of the above, if one of these conditions is met:

    * Any lookup operation failed (:ref:`lookup() <dnslib_funcs_lookup>` returned ``-1``).

**Example:**

.. code-block:: lua

    local dnslib = require("dnslib")
    local domains = {
        "test1.com",
        "test2.com"
    }

    local addresses = dnslib.lookupMultiple(domains)

Here ``addresses`` would contain the addresses of both, ``test1.com`` and ``test2.com``. If either one of those would cause an error in :ref:`lookup() <dnslib_funcs_lookup>`, ``addresses`` would contain ``-1``.