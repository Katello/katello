
Developing for the Katello Python Client
========================================


The Katello Python client is a command-line interface for accessing and using the Katello management software.
The following is a general description of adding commands and actions.
It can also be very helpful to browse around in the client files to see how things are done.

Core
----

New File and Imports
^^^^^^^^^^^^^^^^^^^^

In the case of the Katello CLI, a 'command' specifies the area (or data) in Katello that will be interacted with (e.g. org, environment, provider, etc.)

Create a new file in `katello/cli/src/katello/client/core/`.

It should be named the same as the command (e.g. if the command is 'computer', then the file should be `computer.py`, etc). You'll pick up on the naming scheme quick.

There are a few imports that you need to have included among other imports specific to this command::

    import os
    from gettext import gettext as _

    from katello.client.core.base import BaseAction, Command


Classes
^^^^^^^

You will need at least one class to represent the action.

In most cases, you should also add a class representing a command that encapsulates the action.

The class representing the command is usually very simple. ::

    class Computer(Command):
        description = _('computer specific actions')

It is a good practise co create a base class for your actions.

This is the place where you can create an instance of your api adapter 
or define common methods for retrieving db records. ::

    class ComputerAction(BaseAction):
        def __init__(self):
            super(ComputerAction, self).__init__()
            self.api = ComputerAPI() # if your command has logic that needs to connect with the API, add this line. More on this below.

Then you will create one or more classes for each action to take with your new command. ::

    class TurnOn(ComputerAction):
        description = _('turn on the computer')

        def setup_parser(self, parser):
            # Method for setting custom options.
            # For details see Python optparse documentation and KatelloOption class.
            parser.add_option('--button', dest='button', help=_('which button to push'))

        def check_options(self, validator):
            # Section for checking options. More about option validator under this block.
            validator.require('button')

        def run(self):
            # This method is the actual body of your class. It has usually this scheme:
            #  1. get options
            #  2. retrieve data/do the operation
            #  3. print the result (for printing records we use class Printer that ensures 
            #     consistent output)

            button = self.get_option('button')

            if button == 'power':
                boot_sequence = self.api.push_button(button)
            else:
                return os.EX_DATAERR

            self.printer.add_column('boot_message')
            self.printer.set_header('Booting')
            self.printer.print_item(boot_sequence)
            return os.EX_OK

Detailed description of the used resources:

- `Python optparse <http://docs.python.org/library/optparse.html>`_
- :doc:`option_validator`
- :doc:`option_types`
- :doc:`printer`

API
---

New File and Imports
^^^^^^^^^^^^^^^^^^^^

If your actions need to use the API in some way, the logic specific to the API will be placed in a different location.[[BR]]
To add API functionality to your actions, add a new file to `katello/cli/src/katello/client/api/`. We'll call ours `computer.py` (after the command).

In this file you will want include at least one import ::

    from katello.client.api.base import KatelloAPI
    from katello.client.api.utils import get_environment # you may also need to import other small API calls that have already been implemented
    from katello.client.api.utils import get_computer

Classes
^^^^^^^

There is only going to be one class here ::
    
    class ComputerAPI(KatelloAPI):

        def push_button(self, button_id):
            path = "/api/buttons/%s" % button_id
            return self.server.GET(path)[1]

        ...


More Resources
--------------

- :doc:`command_model`
- :doc:`utils`
- :doc:`api_utils`
- :doc:`cli_generator`




