import unittest
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.template
from katello.client.core.template import Update



class RequiredCLIOptionsTests(CLIOptionTestCase):
    #requires: organization, name
    #optional: NONE

    def setUp(self):
        self.set_action(Update())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['update', '--name=template_1'])

    def test_missing_name_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['update', '--org=ACME'])

    def test_no_error_if_org_and_name_provided(self):
        self.action.process_options(['list', '--org=ACME', '--name=template_1'])
        self.assertEqual(len(self.action.optErrors), 0)


class TemplateUpdateTest(CLIActionTestCase):

    ORG = test_data.ORGS[0]
    ENV = test_data.LIBRARY
    TPL = test_data.TEMPLATES[0]

    TPL_DESC = "description of the template"
    TPL_PARENT_NAME = 'parent_template'
    TPL_PARENT_ID = 83

    OPTIONS = {
        'org':  ORG['name'],
        'name': TPL['name']
    }

    OPTIONS_WITH_PARENT = {
        'org': ORG['name'],
        'name': TPL['name'],
        'parent': TPL_PARENT_NAME
    }

    def setUp(self):
        self.set_action(Update())
        self.set_module(katello.client.core.template)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'templates', test_data.TEMPLATES)

        self.mock(self.module, 'get_environment', self.ENV)
        self.mock(self.module, 'get_library', self.ENV)
        self.mock(self.module, 'get_template', self.TPL)

        self.mock(self.action, 'updateTemplate')
        self.mock(self.action, 'updateContent')

        self.mock_spinner()


    def test_it_finds_the_template_by_name(self):
        self.mock_options(self.OPTIONS)
        self.action.run()
        self.module.get_template.assert_called_with(self.ORG['name'], self.ENV['name'], self.TPL['name'])

    def test_it_returns_error_when_template_not_found(self):
        self.mock(self.module, 'get_template', None)
        self.assertEqual(self.action.run(), os.EX_DATAERR)

    def test_it_finds_parent_template(self):
        self.mock_options(self.OPTIONS_WITH_PARENT)
        self.mock(self.action, 'get_parent_id', self.TPL_PARENT_ID)
        self.action.run()
        self.action.get_parent_id.assert_called_once_with(self.ORG['name'], self.ENV["name"], self.TPL_PARENT_NAME)

    def test_it_returns_error_when_parent_not_found(self):
        self.mock(self.module, 'get_template', None)
        self.assertEqual(self.action.run(), os.EX_DATAERR)

    def test_it_calls_update_template(self):
        self.mock_options(self.OPTIONS)
        self.action.run()
        self.action.updateTemplate.assert_called_once()

    def test_it_calls_update_content(self):
        self.mock_options(self.OPTIONS)
        self.action.run()
        self.action.updateContent.assert_called_once()

    def test_it_returns_status_ok(self):
        self.mock_options(self.OPTIONS)
        self.action.run()
        self.assertEqual(self.action.run(), os.EX_OK)
