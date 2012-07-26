import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase
from katello.tests.core.organization.organization_data import ORGS, ENVS

import katello.client.core.changeset
from katello.client.core.changeset import Create

class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = Create()

    disallowed_options = [
        ('--name=changeset1', ),
        ('--org=ACME', )
    ]

    allowed_options = [
        ('--org=ACME', '--name=changeset1', '--env=DEV', '--promotion', '--deletion')
    ]


class ChangesetAddTest(CLIActionTestCase):
    ORG = 'org'
    NAME = 'changeset1'
    DESCRIPTION = 'description'
    TYPE = 'promotion'

    OPTIONS = {
        'org':ORG,
        'name':NAME,
        'description':DESCRIPTION,
        'type':TYPE
    }

    def setUp(self):
        self.set_action(Create())
        self.set_module(katello.client.core.changeset)
        self.mock_printer()
        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'create', [])
        self.mock(self.module, 'get_environment', ENVS[0])

    def tearDown(self):
        self.restore_mocks()


    def test_it_uses_filter_create_api(self):
        self.run_action()
        self.action.api.create.assert_called_once_with(self.ORG, ENVS[0]['id'], self.NAME, self.DESCRIPTION, self.TYPE)
