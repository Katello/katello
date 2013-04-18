import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase,\
        CLIActionTestCase

import katello.client.core.content_view_definition
from katello.client.core.content_view_definition import Delete

class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = Delete()

    disallowed_options = [
        ('--label=content_view1', ),
        ('--org=ACME', )
    ]

    allowed_options = [
        ('--org=ACME', '--label=content_view1')
    ]


class ContentViewDeleteTest(CLIActionTestCase):

    ORG = 'org'
    VIEW = { "label": 'content_view',
             "name": "content_view",
             "id": 1
            }

    OPTIONS = {
        'org':ORG,
        'label':VIEW["label"]
    }

    def setUp(self):
        self.set_action(Delete())
        self.set_module(katello.client.core.content_view_definition)
        self.mock_printer()
        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'delete')
        self.mock(self.module, "get_cv_definition", self.VIEW)

    def tearDown(self):
        self.restore_mocks()

    def test_it_uses_content_view_delete_api(self):
        self.run_action()
        self.action.api.delete.assert_called_once_with(self.VIEW["id"])
