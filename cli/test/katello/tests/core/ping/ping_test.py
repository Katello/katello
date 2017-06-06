import unittest
import os
from mock import Mock
from copy import deepcopy

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase

from katello.tests.core.ping import ping_data

import katello.client.core.ping
from katello.client.core.ping import Status



class PingTest(CLIActionTestCase):


    def setUp(self):
        self.set_action(Status())
        self.set_module(katello.client.core.ping)

        self.mock(self.action.api, 'ping', ping_data.PING_STATUS)
        self.mock_printer()


    def test_calls_the_api(self):
        self.run_action()
        self.action.api.ping.assert_called_once()

    def test_it_returns_correct_error_code_when_all_systems_up(self):
        self.run_action(os.EX_OK)

    def test_it_returns_correct_error_codes(self):
        self.check_return_code(['candlepin'], 2)
        self.check_return_code(['candlepin_auth'], 4)
        self.check_return_code(['pulp'], 8)
        self.check_return_code(['pulp_auth'], 16)

        self.check_return_code(['candlepin', 'candlepin_auth'], 6)
        self.check_return_code(['pulp', 'pulp_auth'], 24)

        self.check_return_code(['candlepin', 'candlepin_auth', 'pulp', 'pulp_auth'], 30)

    def check_return_code(self, failed_services, expected_code):
        status = deepcopy(ping_data.PING_STATUS)
        for s in failed_services:
            status['status'][s]['result'] = 'failed'

        self.mock(self.action.api, 'ping', status)

        self.run_action(expected_code)
