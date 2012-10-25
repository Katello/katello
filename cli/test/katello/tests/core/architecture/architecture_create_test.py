import os

from katello.tests.core.action_test_utils import CLIOptionTestCase

from katello.tests.core.architecture.architecture_base_test import ArchitectureBaseTest
from katello.client.core.architecture import Create


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #required:
    action = Create()

    allowed_options = [
        ('--name=', )
    ]


class ArchitectureCreateTest(ArchitectureBaseTest):

    OPTIONS = {
        'name': ArchitectureBaseTest.ARCH_NAME
    }

    def setUp(self):
        self.set_action(Create())
        self.mock(self.action.api, 'create', self.ARCH)
        super(ArchitectureCreateTest, self).setUp()


    def test_calls_the_api(self):
        self.run_action()
        self.action.api.create.assert_called_once_with({'name': self.ARCH_NAME})

    def test_it_didnt_pass_validation(self):
        self.mock(self.action.api, 'create', None)
        self.run_action(os.EX_DATAERR)

    def test_returns_ok(self):
        self.run_action(os.EX_OK)
