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

* :ref:`ecnet (Third Party) <ecnet>`








.. _comlib_funcs:

Functions
---------

* :ref:`open() <comlib_funcs_open>`
* :ref:`getAddress() <comlib_funcs_getAddress>`
* :ref:`sendRequest() <comlib_funcs_sendRequest>`
* :ref:`sendResponse() <comlib_funcs_sendResponse>`
* :ref:`broadcast() <comlib_funcs_broadcast>`

.. _comlib_funcs_open:

open()
^^^^^^

Opens secure connection on modem on specified side

.. code-block:: lua

    function comlib.open(side)
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
    * - ``table``
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

    function comlib.getAddress()
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

.. _comlib_funcs_sendRequest:

sendRequest()
^^^^^^^^^^^^^

Creates a request packet with the status ``REQUEST``, sends it to the specified address
and will wait for and return a response packet.
This function will return ``-1`` if the receiving operation times out.

.. code-block:: lua

    function sendRequest(address, header, contents, timeout)
        ...
        return response
    end

**Arguments:**

.. list-table::
    :widths: 20 20 20 40
    :header-rows: 1

    * - Name
      - Type
      - Default
      - Description
    * - **address**
      - ``string``
      - ``nil``
      - Address of the receiver.
    * - **header**
      - ``string``
      - ``nil``
      - Header of the request packet.
    * - **contents**
      - ``table``
      - ``nil``
      - Additional contents of the request packet.
    * - **timeout**
      - ``number``
      - ``3``
      - Number of seconds before the timeout would get triggered.

.. note:: 
    Additional contents depend on the type of request and what the receiver is expecting

**Returns:**

.. list-table::
    :widths: 20 80
    :header-rows: 1

    * - Type
      - Description
    * - ``table``
      - Received response packet.

.. warning::
    This function returns ``-1`` instead of the above, if one of these conditions is met:
  
    * Not being able to connect to the address.
    * Sender of the response packet is ``nil``.
    * Deserialized response packet is ``nil``.
    * If response header does not match request header.

**Example:**

.. code-block:: lua

    local comlib = require("comlib")
    comlib.sendRequest("873b:a87c:fe93:846:c9d3", "GET", {key = "Hello"}, 3)

In this example, a request packet with the **header** ``"GET"`` and the **contents** ``{key = "Hello"}`` will be sent to ``"873b:a87c:fe93:846:c9d3"``.
For this example, we will assume that the receiver expects ``key`` in **contents**, which is why ``key = "Hello"`` is specified here.
If no response is received within ``3`` seconds, the function would timeout and return ``-1``.

Created packet: ``{head = "GET", status = "REQUEST", contents = {key = "Hello"}}``

----

.. _comlib_funcs_sendResponse:

sendResponse()
^^^^^^^^^^^^^^

Sends a response to the specified receiver with specified head, status and additional contents

.. code-block:: lua

    function comlib.sendResponse(address, header, status, contents)
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
    * - **address**
      - ``string``
      - ``nil``
      - Address of the receiver.
    * - **header**
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

**Returns:** ``nil``

**Example:**

.. code-block:: lua

    local comlib = require("comlib")
    comlib.sendResponse("b38a:a780:bd82:cd56:195f", "GET", "OK", {value = "Test"})

In this example, a response packet with the header ``"GET"`` and the status ``"OK"`` will be sent to ``"b38a:a780:bd82:cd56:195f"``.
For this example, we will assume that the receiver expects ``value`` in **contents**, which is why ``value = "Test"`` is specified here.

Created packet: ``{head = "GET", status = "OK", contents = {value = "Test"}}``

----

.. _comlib_funcs_broadcast:

broadcast()
^^^^^^^^^^^

Broadcasts a request to multiple receivers and collects all responses. If a response of a receiver fails (:ref:`sendRequest <comlib_funcs_sendRequest>` returns ``-1``), its response will fall back to this one: ``{head = header, status = "FAIL", contents = {}}``.

.. note:: 
  This function calls :ref:`sendRequest() <comlib_funcs_sendRequest>` for each receiver.

.. code-block:: lua

    function comlib.broadcast(addresses, header, contents, timeout)
      ...
      return responses
    end

**Arguments:**

.. list-table::
    :widths: 20 20 20 40
    :header-rows: 1

    * - Name
      - Type
      - Default
      - Description
    * - **addresses**
      - ``table``
      - ``nil``
      - Addresses of the receivers.
    * - **header**
      - ``string``
      - ``nil``
      - Header of the response packet.
    * - **contents**
      - ``table``
      - ``nil``
      - Additional contents to add to the packet.
    * - **timeout**
      - ``number``
      - ``3``
      - Number of seconds before the timeout would get triggered.

.. note:: 
    Additional contents depend on the type of response and what the receiver is expecting

**Returns:**

.. list-table::
    :widths: 20 80
    :header-rows: 1

    * - Type
      - Description
    * - ``table``
      - Received response packets.

**Example:**

.. code-block:: lua

    local comlib = require("comlib")
    local responses = {}
    local receivers = {
      "01ae:4a1e:0195:6e6e:56af",
      "e990:4b07:961f:0b4b:c50a:",
      "7a57:2c08:9d08:7bac:91ff"
    }

    responses = comlib.broadcast(receivers, "TEST", {})

This would send the packet ``{head = "TEST", status = "REQUEST", contents = {}}`` to all three specified receivers and would store there responses in ``responses``.