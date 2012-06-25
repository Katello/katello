import unittest
import os
from mock import Mock

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase
from katello.tests.core.version import version_data

import katello.client.core.version
from katello.client.core.version import Info


class VersionTest(CLIActionTestCase):

    def setUp(self):
        self.set_action(Info())
        self.set_module(katello.client.core.version)
        self.mock(self.action.api, 'version_formatted', version_data.VERSION_INFO)

    def test_calls_the_api(self):
        self.run_action()
        self.action.api.version_formatted.assert_called_once()
