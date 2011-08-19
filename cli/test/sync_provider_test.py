import unittest
from mock import Mock
import os

import katello.client.core.provider
from katello.client.core.provider import Sync

try:
    import json
except ImportError:
    import simplejson as json


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
        
class SyncTest(unittest.TestCase):
    
    PROVIDER = 'provider'
    PROVIDER_ID = '123'
    ORGANIZATION = 'org'
    SYNC_TASK = {}
    SYNC_RESULT_WITHOUT_ERROR = [{'state':'finished'}, {'state':'finished'}]
    SYNC_RESULT_WITH_ERROR = [{'state':'error', 'result':json.dumps({'errors':["some error"]})}, {'state':'finished'}]
    
    def setUp(self):
        self.original_get_provider = katello.client.core.provider.get_provider
        katello.client.core.provider.get_provider = Mock()
        katello.client.core.provider.get_provider.return_value = { 'id':self.PROVIDER_ID }
        
        self.original_run_async_task_with_status = katello.client.core.provider.run_async_task_with_status
        katello.client.core.provider.run_async_task_with_status = Mock()
        katello.client.core.provider.run_async_task_with_status.return_value = self.SYNC_RESULT_WITHOUT_ERROR

        self.sync_action = Sync()
        
        self.sync_action.api.sync = Mock()
        self.sync_action.api.sync.return_value = self.SYNC_TASK        
        
    def tearDown(self):
        katello.client.core.provider.get_provider = self.original_get_provider
        katello.client.core.provider.run_async_task_with_status = self.original_run_async_task_with_status
        
    def test_finds_provider(self):
        self.sync_action.sync_provider(self.PROVIDER, self.ORGANIZATION)
        katello.client.core.provider.get_provider.assert_called_once_with(self.ORGANIZATION, self.PROVIDER)
        
    def test_returns_with_error_when_no_provider_found(self):
        katello.client.core.provider.get_provider.return_value = None
        self.assertEqual(self.sync_action.sync_provider(self.PROVIDER, self.ORGANIZATION), os.EX_DATAERR)
        
    def test_calls_sync_api(self):
        self.sync_action.sync_provider(self.PROVIDER, self.ORGANIZATION)
        self.sync_action.api.sync.assert_called_once_with(self.PROVIDER_ID)
        
    def test_waits_for_sync(self):
        self.sync_action.sync_provider(self.PROVIDER, self.ORGANIZATION)
        katello.client.core.provider.run_async_task_with_status.assert_called_once
        
    def test_returns_ok_when_sync_was_successful(self):
        self.assertEqual(self.sync_action.sync_provider(self.PROVIDER, self.ORGANIZATION), os.EX_OK)
        
    def test_returns_error_if_sync_failed(self):
        katello.client.core.provider.run_async_task_with_status.return_value = self.SYNC_RESULT_WITH_ERROR
        self.assertEqual(self.sync_action.sync_provider(self.PROVIDER, self.ORGANIZATION), os.EX_DATAERR)
        
        
    
        

