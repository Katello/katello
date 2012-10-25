import os

from katello.tests.core.action_test_utils import CLIOptionTestCase

from katello.tests.core.architecture.architecture_base_test import ArchitectureBaseTest
from katello.client.core.architecture import Show
from katello.client.server import ServerRequestError

class RequiredCLIOptionsTests(CLIOptionTestCase):
    #required: name
    action = Show()

    allowed_options = [
        ('--name=x86_64', )
    ]


class ArchitectureInfoTest(ArchitectureBaseTest):

    OPTIONS = {
        'name': ArchitectureBaseTest.ARCH_NAME
    }

    def setUp(self):
        self.set_action(Show())
        self.mock(self.action.api, 'show', self.ARCH)
        super(ArchitectureInfoTest, self).setUp()

    def test_finds_architecture(self):
        self.run_action()
        self.action.api.show.assert_called_once_with(self.ARCH_NAME)

    def test_fails_when_arch_not_found(self):
        self.mock(self.action.api, 'show').side_effect = ServerRequestError(os.EX_DATAERR)
        self.run_action(os.EX_DATAERR)

    def test_returns_ok(self):
        self.run_action(os.EX_OK)
