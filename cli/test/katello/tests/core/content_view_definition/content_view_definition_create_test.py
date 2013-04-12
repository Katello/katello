import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, \
        CLIActionTestCase

import katello.client.core.content_view_definition
from katello.client.core.content_view_definition import Create

class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = Create()

    disallowed_optinos = [
        ('--name=MyRHEL', ),
        ('--org=ACME_Corporation', ),
        ('--org=ACME_Corporation', '--label=Test', )
    ]

    allowed_options = [
        ('--org=ACME_Corporation', '--name=MyRHEL'),
        ('--org=ACME_Corporation', '--name=MyRHEL', '--composite'),
        ('--org=ACME_Corporation', '--name=MyRHEL', '--label=MyRHEL', '--composite')
    ]

class ContentViewAddTest(CLIActionTestCase):
    ORG = 'org'
    NAME = 'MyRHEL'
    LABEL = ''
    DESCRIPTION = 'description'

    OPTIONS = {
        'org': ORG,
        'name': NAME,
        'description': DESCRIPTION,
        'label': LABEL
    }

    def setUp(self):
        self.set_action(Create())
        self.set_module(katello.client.core.content_view)
        self.mock_printer()
        self.mock_options(self.OPTIONS)

        self.mock(self.action.def_api, 'create', [])

    def tearDown(self):
        self.restore_mocks()

    def test_it_uses_def_api(self):
        self.run_action()
        self.action.def_api.create.assert_called_once_with(
            self.ORG, self.NAME, self.LABEL, self.DESCRIPTION, None)
