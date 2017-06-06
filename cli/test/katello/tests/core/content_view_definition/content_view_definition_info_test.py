import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase,\
        CLIActionTestCase

import katello.client.core.content_view_definition
from katello.client.core.content_view_definition import Info

class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = Info()

    disallowed_options = [
        ('--label=content_def1', ),
        ('--label=content_def1', '--id=1', '--org=ACME', ),
        ('--org=ACME', )
    ]

    allowed_options = [
        ('--org=ACME', '--label=content_def1'),
        ('--org=ACME', '--id=content_def1'),
        ('--org=ACME', '--name=content_def1'),
    ]


class ContentViewInfoTest(CLIActionTestCase):

    ORG = 'org'
    DEF = { "label": 'content_def',
             "id": 1
            }

    OPTIONS = {
        'org':ORG,
        'label':DEF["label"]
    }

    def setUp(self):
        self.set_action(Info())
        self.set_module(katello.client.core.content_view_definition)
        self.mock_printer()
        self.mock_options(self.OPTIONS)

        self.mock(self.module, 'get_cv_definition', self.DEF)

    def tearDown(self):
        self.restore_mocks()

    def test_it_uses_content_view_show_api(self):
        self.run_action()
        self.module.get_cv_definition.assert_called_once_with(self.ORG,
                self.DEF["label"], None, None)
