import os

from katello.tests.core.action_test_utils import CLIActionTestCase
from katello.tests.core.architecture.architecture_data import ARCHS

import katello.client.core.architecture

class ArchitectureBaseTest(CLIActionTestCase):

    ARCHS = ARCHS
    ARCH = ARCHS[0]
    ARCH_NAME = ARCH["architecture"]["name"]
    OPTIONS = None

    def setUp(self):
        self.set_module(katello.client.core.architecture)
        self.mock_printer()

        if self.OPTIONS:
            self.mock_options(self.OPTIONS)

