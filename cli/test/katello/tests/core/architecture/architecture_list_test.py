import os

from katello.tests.core.action_test_utils import CLIOptionTestCase

from katello.tests.core.architecture.architecture_base_test import ArchitectureBaseTest
from katello.client.core.architecture import List


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #required:
    action = List()

    allowed_options = [
        ()
    ]


class ArchitectureListTest(ArchitectureBaseTest):

    def setUp(self):
        self.set_action(List())
        self.mock(self.action.api, 'index', self.ARCHS)
        super(ArchitectureListTest, self).setUp()

    def test_calls_the_api(self):
        self.run_action()
        self.action.api.index.assert_called_once()

    def test_returns_ok_even_if_the_list_is_empty(self):
        self.mock(self.action.api, 'index', [])
        self.run_action(os.EX_OK)    

    def test_returns_ok(self):
        self.run_action(os.EX_OK)
