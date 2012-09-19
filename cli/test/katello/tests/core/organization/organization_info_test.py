import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase

from katello.tests.core.organization.organization_data import ORGS

import katello.client.core.organization
from katello.client.core.organization import Info


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #required: name

    action = Info()

    disallowed_options = [
        ()
    ]

    allowed_options = [
        ('--name=role1', )
    ]


class OrgInfoTest(CLIActionTestCase):

    ORG = ORGS[0]

    OPTIONS = {
        'name': ORG['name']
    }

    def setUp(self):
        self.set_action(Info())
        self.set_module(katello.client.core.organization)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'organization', self.ORG)

    def test_finds_org(self):
        self.run_action()
        self.action.api.organization.assert_called_once_with(self.ORG['label'])

    def test_returns_ok(self):
        self.run_action(os.EX_OK)
