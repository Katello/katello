import unittest
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase
from katello.tests.core.organization import organization_data
from katello.tests.core.template import template_data

import katello.client.core.template
from katello.client.core.template import Create
from katello.client.api.utils import ApiDataError


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #requires: name, organization

    action = Create()

    disallowed_options = [
        ('--name=template_1', ),
        ('--org=ACME', ),
    ]

    allowed_options = [
        ('--org=ACME', '--name=template_1'),
    ]


class TemplateCreateTest(CLIActionTestCase):

    ORG = organization_data.ORGS[0]
    TPL = template_data.TEMPLATES[0]
    LIBRARY = organization_data.LIBRARY

    TPL_DESC = "description of the template"
    TPL_PARENT_NAME = 'parent_template'
    TPL_PARENT_ID = 83

    OPTIONS = {
        'org': ORG['name'],
        'name': TPL['name'],
        'description': TPL_DESC
    }

    OPTIONS_WITH_PARENT = {
        'org': ORG['name'],
        'name': TPL['name'],
        'description': TPL_DESC,
        'parent': TPL_PARENT_NAME
    }

    def setUp(self):
        self.set_action(Create())
        self.set_module(katello.client.core.template)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'create', self.TPL)
        self.mock(self.action, 'get_parent_id', None)

        self.mock(self.module, 'get_library', self.LIBRARY)

    def test_it_finds_library_environment(self):
        self.run_action()
        self.module.get_library.assert_called_once_with(self.ORG['name'])

    def test_it_returns_error_when_library_not_found(self):
        self.mock(self.module, 'get_library').side_effect = ApiDataError
        self.run_action(os.EX_DATAERR)

    def test_it_finds_parent_template(self):
        self.mock_options(self.OPTIONS_WITH_PARENT)
        self.mock(self.action, 'get_parent_id', self.TPL_PARENT_ID)
        self.run_action()
        self.action.get_parent_id.assert_called_once_with(self.ORG['name'], self.LIBRARY["name"], self.TPL_PARENT_NAME)

    def test_it_calls_create_api(self):
        self.run_action()
        self.action.api.create.assert_called_once_with(self.LIBRARY['id'], self.TPL["name"], self.TPL_DESC, None)

    def test_it_calls_create_api_with_parent_id(self):
        self.mock_options(self.OPTIONS_WITH_PARENT)
        self.mock(self.action, 'get_parent_id', self.TPL_PARENT_ID)
        self.run_action()
        self.action.api.create.assert_called_once_with(self.LIBRARY['id'], self.TPL["name"], self.TPL_DESC, self.TPL_PARENT_ID)

    def test_it_returns_error_when_creation_failed(self):
        self.mock(self.action.api, 'create', {})
        self.run_action(os.EX_DATAERR)

    def test_it_success_on_successful_creation(self):
        self.run_action(os.EX_OK)
