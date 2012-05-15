import unittest
from mock import Mock
import os
from cli_test_utils import CLIOptionTestCase
import test_data

import katello.client.core.provider
from katello.client.core.provider import SingleProviderAction

try:
    import json
except ImportError:
    import simplejson as json


class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = SingleProviderAction()

    disallowed_options = [
        ('--name=provider', ),
        ('--org=ACME', ),
    ]

    allowed_options = [
        ('--org=ACME', '--name=provider', ),
    ]
