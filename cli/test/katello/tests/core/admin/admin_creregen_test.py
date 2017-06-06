import os
from cli_test_utils import CLIActionTestCase

import katello.client.core.admin
from katello.client.core.admin import CrlRegen

class AdminCrlRegenTest(CLIActionTestCase):

    def setUp(self):
        self.set_action(CrlRegen())
        self.set_module(katello.client.core.admin)

        self.mock(self.action.api, 'crl_regen', None)
        self.mock_printer()

    def test_calls_the_api(self):
        self.run_action()
        self.action.api.crl_regen.assert_called_once()

    def test_it_returns_correct_error_code_when_all_systems_up(self):
        self.run_action(os.EX_OK)
