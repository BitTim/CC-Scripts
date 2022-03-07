.. _essentia:

Essentia
========

.. note:: 
    This app is created for use with Thaumcraft 6

.. _essentia_overview:

Overview
--------

Essentia is a set of scripts to control the flow of essentia from an essentia storage room, similar to `this one <https://youtu.be/e5spYffkuNs>`_\ , through one pipe
to a consuming machine, like the Thaumatorium.

The app is broken down into 3 scripts, which run on different computers:

* :ref:`Controller <essentia_docs_controller>`
* :ref:`Server <essentia_docs_server>`
* :ref:`Display <essentia_docs_display>`

.. warning::
    Essentia can only be moved in multiples of 5, due to a limitation in the redstone contraption for consistency reasons



.. _essentia_dependencies:

Dependencies
------------

Mods
^^^^

* `Thaumcraft 6 <https://www.curseforge.com/minecraft/mc-mods/thaumcraft>`_
* `Project Red - Core <https://www.curseforge.com/minecraft/mc-mods/project-red-core>`_
* `Project Red - Integration <https://www.curseforge.com/minecraft/mc-mods/project-red-integration>`_
* `Project Red - Transmission <https://www.curseforge.com/minecraft/mc-mods/project-red-transmission>`_
* `NBT Peripheral <https://www.curseforge.com/minecraft/mc-mods/nbt-peripheral>`_

Structures
^^^^^^^^^^

ToDo: Insert images here

.. note:: 
    You also need to have your :ref:`DNS infrastructure <dns>` set up and running.

.. _essentia_setup:

Setup
-----

Prequisites
^^^^^^^^^^^

* Each jar in your storage room has to be labled.
* Each jar in your storage room needs to be part of a flow control structure.
* For every **15 jars**, you need a **controller**
* For the **controller**, you need a computer with a **wireless mdoem**.
* For the **server**, you need a computer with an **ender modem**.
* For the **display**, you will need a computer with a **wireless modem** and a **5 x 2** monitor.

.. important:: 
    The ender modem is required for the server to lift the distance limit for transmissions

.. note::
    It is recommended to attach a disk drive and a monitor of any size to the server

Automated
^^^^^^^^^

.. danger:: 
    The automated installer is not yet implemented. This section is prewritten for the future.

You need to run the automated installer on every computer placed in the previous step and select the correct install type.
To run and execute the autmated installer, run these commands. The installer will accommodate configuring the computer accordingly:

.. code-block:: console

    wget https://github.com/BitTim/CC-Scripts/src/apps/Essentia/install.lua
    install


Manual
^^^^^^

ToDo: Insert installation instructions


.. note:: 
    The automated install is recommended.


.. _essentia_docs:

Documentation
-------------

.. toctree:: 
    
    controller
    server
    display