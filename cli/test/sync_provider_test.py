import unittest
from mock import Mock

import katello.client.core.provider
from katello.client.core.provider import Sync

class RequiredCLIOptionsTests(unittest.TestCase):
    def setUp(self):
        self.sync_action = Sync()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.sync_action.process_options, ['sync', '--name=provider'])

    def test_missing_name_generates_error(self):
        self.assertRaises(Exception, self.sync_action.process_options, ['sync', '--org=ACME'])

    def test_no_error_if_required_options_provided(self):
        self.sync_action.process_options(['sync', '--org=ACME', '--name=provider'])
        self.assertEqual(len(self.sync_action.optErrors), 0)
        

