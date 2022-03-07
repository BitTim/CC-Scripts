.. _comlib:

ComLib
======

A library for communicating between two computers in a server and client relation

**Contents:**

* :ref:`Dependencies <comlib_deps>`
* :ref:`Functions <comlib_funcs>`








.. _comlib_deps:

Dependencies
------------

* :ref:`ecnet <ecnet>`








.. _comlib_funcs:

Functions
---------

* :ref:`open(side) <comlib_funcs_open>`
* :ref:`getAddress() <comlib_funcs_getAddress>`
* :ref:`sendResponse(s, head, status, contents) <comlib_funcs_sendResponse>`

.. _comlib_funcs_open:

open(side)
^^^^^^^^^^

Opens secure connection on modem on specified side

.. code-block:: lua

    local funtion open(side)
        ...
        return sModem
    end

**Arguments:**

.. list-table::
    :widths: 20 20 20 40
    :header-rows: 1

    * - Name
      - Type
      - Default
      - Description
    * - **side**
      - ``string``
      - ``nil``
      - Side of the modem for the secure connection.

**Returns:** 

.. list-table::
    :widths: 20 80
    :header-rows: 1

    * - Type
      - Description
    * - ``sModem``
      - Instance of secure modem object.

**Example:**

.. code-block:: lua

    local comlib = require("comlib")
    local sModem = comlib.open("front")

This would open a secure connection on the modem at the front of the computer, accessible with the ``sModem`` variable.

----

.. _comlib_funcs_getAddress:

getAddress()
^^^^^^^^^^^^

Returns address of current computer

.. code-block:: lua

    local funtion getAddress()
        ...
        return address
    end

**Arguments:** ``nil``

**Returns:** 

.. list-table::
    :widths: 20 80
    :header-rows: 1

    * - Type
      - Description
    * - ``string``
      - Address of current computer.

**Example:**

.. code-block:: lua

    local comlib = require("comlib")
    print(comlib.getAddress())

This would print the address of the current computer, e.g. ``b38a:a780:bd82:cd56:195f``

----

.. _comlib_funcs_sendResponse:

sendResponse(rec, head, status, contents)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Sends a response to the specified receiver with specified head, status and additional contents

.. code-block:: lua

    local funtion sendResponse(rec, head, status, contents)
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
    * - **rec**
      - ``string``
      - ``nil``
      - Address of the receiver.
    * - **head**
      - ``string``
      - ``nil``
      - Header of the response packet.
    * - **status**
      - ``string``
      - ``nil``
      - Status of the response packet (e.g. "OK" or "FAIL").
    * - **contents**
      - ``table``
      - ``nil``
      - Additional contents to add to the packet.

.. note:: 
    Additional contents depend on the type of response and what the receiver is expecting

**Example:**

.. code-block:: lua

    local comlib = require("comlib")
    comlib.sendResponse("b38a:a780:bd82:cd56:195f", "GET", "OK", {value = "Test"})

In this example, a response packet for the header ``"GET"`` and the status ``"OK"`` will be sent to ``"b38a:a780:bd82:cd56:195f"``. For this example, we will assume that the receiver expects a value in **contents**, which is why ``value = "Test"`` is specified here.

**Returns:** ``nil``