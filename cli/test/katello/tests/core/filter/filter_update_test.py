# this is a test
import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase

import katello.client.core.filters
from katello.client.core.filters import Update

class RequiredCLIOptionsTests(CLIOptionTestCase):

  action = Update()

  disallowed_options = [
      ('--name=filter1', ),
      ('--org=ACME', ),
      ('--new-name=filter1', )
  ]

  allowed_options = [
      ('--org=ACME', '--name=filter1', '--new-name=filter0')
  ]

class FilterUpdateTest(CLIActionTestCase):
  ORG = 'org'
  FILTER = 'filter'
  NAME = 'filter0'

  OPTIONS = {
      'org':ORG,
      'name':FILTER,
      'new_name':NAME
  }

  def setUp(self):
    self.set_action(Update())
    self.set_module(katello.client.core.filters)
    self.mock_printer()
    self.mock_options(self.OPTIONS)

    self.mock(self.action.api, 'update', { 'name': self.NAME })

  def tearDown(self):
    self.restore_mocks()

  def test_it_uses_filter_update_api(self):
    self.run_action()
    self.action.api.update.assert_called_once_with(self.ORG, self.FILTER, self.NAME)
