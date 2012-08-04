Printing unified output
=======================

For unified output of Katello CLI we use an instance of a printer class. Printer makes a common interface that supports multiple formatting strategies.
Currently a verbose strategy and a grep friendly strategy is implemented. The first is by default used to display single dictionaries while the latter is used to print
lists of dictionaries.

Before the records are printed it is necessary to restrict what columns will go to the output. This is done by function add_column which allows to set various column parameters.

Printer offers following methods (only the public ones listed):

Printer
^^^^^^^
.. autoclass:: katello.client.utils.printer.Printer
   :members:
   :inherited-members:



Print strategies
^^^^^^^^^^^^^^^^


Printer strategies have to implement methods print_item and print_items that take care of printing a single record or a list of them.
They both take heading label, definition of columns (list of dictionaries) and the data.

Two strategies are used in CLI:

* :ref:`VerboseStrategy<verbose>` - prints each column on a single line
* :ref:`GrepStrategy<grep>` - prints the data in a grid, one record per line



.. autoclass:: katello.client.utils.printer.PrinterStrategy
   :members:
   :inherited-members:


**Column Parameters**
Both print strategies support following column parameters:

==============  ==================================  ===========
Name            Type                                Description
==============  ==================================  ===========
attr_name       string                              Mandatory param, key to the data dictionary.
name            string                              Label for the column. By default it is generated from the attr_name. Eg. "product_id" is translated to "Product Id".
multiline       bool                                Flag to mark values that can possibly hold strings with more lines. Strategies can handle them differently then.
formatter       function                            A filter function for pre-formatting of values. Must take only one parameter which is the value that should be formatted. It is expected to return a string.
item_formatter  function                            A filter function simmilar to formatter. The difference is in the parameter. This one takes the whole data dictionary. But still it must return single string.
value           string                              Can be used to force static value.
show_with       strategy or a tuple of strategies   Allows to restrict what strategies the column can be printed with.
==============  ==================================  ===========

.. _verbose:

VerboseStrategy
^^^^^^^^^^^^^^^
.. autoclass:: katello.client.utils.printer.VerboseStrategy

.. _grep:

GrepStrategy
^^^^^^^^^^^^
.. autoclass:: katello.client.utils.printer.GrepStrategy

Usage example
^^^^^^^^^^^^^

.. code-block:: python
    :linenos:

    from katello.client.utils.printer import Printer, VerboseStrategy, GrepStrategy

    repo = get_repo() #returns a dictionary with repo data
    # {
    #   "id": 1,
    #   "pulp_id": "ACME_Corporation-zoo-zoo",
    #   "name": "zoo",
    #   "package_count": 32,
    #   "url": "http://tstrachota.fedorapeople.org/dummy_repos/zoo/",
    #   "last_sync": "2012-04-16T00:27:37+02:00",
    #   "sync_state": "finished"
    # }

    printer = Printer()
    printer.set_strategy(VerboseStrategy()) # set a desired strategy
    #printer.set_strategy(GrepStrategy(delimiter="|"))

    printer.add_column('id') # 3 columns that only print the values
    printer.add_column('name')
    printer.add_column('package_count')
    printer.add_column('url', show_with=VerboseStrategy) # this column will be printed only in the verbose mode
    printer.add_column('last_sync', show_with=VerboseStrategy, formatter=format_sync_time) # only in verbose mode but preformatted by format_sync_time
    printer.add_column('sync_state', name=_("Progress"), show_with=VerboseStrategy, formatter=format_sync_state) # same as above but with forced label

    printer.set_header(_("Information About Repo %s") % repo['id'])

    printer.print_item(repo)


Verbose strategy will print:

.. code-block:: text
    :linenos:

    -------------------------------------------------------------------------------------------------
    Information About Repo 1
    -------------------------------------------------------------------------------------------------

    Id:            1
    Name:          zoo
    Package Count: 32
    Url:           http://tstrachota.fedorapeople.org/dummy_repos/zoo/
    Last Sync:     2012/04/16 00:27:37
    Progress:      Finished


With grep strategy it will print:

.. code-block:: text
    :linenos:

    -------------------------------------------------------------------------------------------------
    Information About Repo 1

    | Id  | Name  | Package Count  |
    -------------------------------------------------------------------------------------------------
    | 1   | zoo   | 32             |


