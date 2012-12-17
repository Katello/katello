import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase

import katello.client.core.content_view
from katello.client.core.content_view import List


class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = List()

    disallowed_options = [
        ('--name=view1', )
    ]

    allowed_options = [
        ('--org=ACME', ),
        ('--org=ACME', '--env=Dev', )
    ]

class ContentViewListTest(CLIActionTestCase):

    ORG = 'some_org'
    OPTIONS = {'org':ORG}

    def setUp(self):
        self.set_action(List())
        self.set_module(katello.client.core.content_view)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'content_views_by_org', [])

    def tearDown(self):
        self.restore_mocks()

    def test_it_uses_lists_api(self):
        self.run_action()
        self.action.api.content_views_by_org.assert_called_once_with(self.ORG,
                None)

