CLI generator utility
=====================

Description:

  This utility semi-automatically generates python code for Katello CLI
  based on json exports from `apipie <https://github.com/Pajk/apipie-rails/>`_  documentation tool.

  It generates:

  * python bindings for the documented api 
        (goes into: /katello/client/api/<RESOURCE_NAME>.py)
  * code for cli command                   
        (goes into: /katello/client/core/<RESOURCE_NAME>.py)
  * code frame for actions                 
        (goes into: /katello/client/core/<RESOURCE_NAME>.py)
  * code for wiring commands and actions into the cli 
        (goes into: /katello/client/main.py)

  The tool uses `inflectorpy <http://code.google.com/p/inflectorpy/>`_ 
  and requires `python-mako <http://www.makotemplates.org/>`_ 
  templating library installed.


Options
^^^^^^^

    -h, --help                        show this help message and exit
    --binding, --api                  generate python api bindings
    --command                         generate cli command frame
    --action                          generate cli action for a method
    --main                            generate code for wiring commands and actions into cli
    -r RESOURCE, --resource=RESOURCE  resource name
    -m METHOD, --method=METHOD        resource's method (eg. index, show, create...)
    -i INPUT, --input=INPUT           input file with json apipie documentation export


Example usage
^^^^^^^^^^^^^
::

    curl http://foreman-rhel:3000/apidoc.json | ./generate.py --resource operatingsystems --api
    curl http://foreman-rhel:3000/apidoc.json | ./generate.py --resource operatingsystems --command
    curl http://foreman-rhel:3000/apidoc.json | ./generate.py --resource operatingsystems --method index --action
    curl http://foreman-rhel:3000/apidoc.json | ./generate.py --resource operatingsystems --main

or ::

    wget http://foreman-rhel:3000/apidoc.json
    ./generate.py --resource operatingsystems --api -i ./apidoc.json


