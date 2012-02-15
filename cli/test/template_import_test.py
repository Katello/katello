import unittest
import os
import __builtin__

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.template
from katello.client.core.template import Import



class RequiredCLIOptionsTests(CLIOptionTestCase):
    #requires: organization, file

    def setUp(self):
        self.set_action(Import())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['import', '--file=/a/b/c/template.import'])

    def test_missing_file_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['import', '--org=ACME'])

    def test_no_error_if_org_and_file_provided(self):
        self.action.process_options(['import', '--org=ACME', '--file=/a/b/c/template.import'])
        self.assertEqual(len(self.action.optErrors), 0)



class TemplateImportTest(CLIActionTestCase):

    ORG = test_data.ORGS[0]
    LIBRARY = test_data.ENVS[0]
    TPL = test_data.TEMPLATES[0]

    OPTIONS = {
        'org': ORG['name'],
        'file': "/a/b/c/template.import"
    }

    open_file = None

    def setUp(self):
        self.set_action(Import())
        self.set_module(katello.client.core.template)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.module, 'get_library', self.LIBRARY)
        self.mock(self.module, 'run_spinner_in_bg')
        self.mock(self.module, '_', "")

        self.mock(self, 'open_file')
        self.mock(self.open_file, 'close')
        self.open_file = self.mock(self.action, 'open_file', self.open_file).return_value
        self.mock(self.action.api, 'import_tpl', 'Import successfull')


    def test_it_opens_the_file(self):
        self.action.run()
        self.action.open_file.assert_called_once_with(self.OPTIONS['file'])

    def test_it_returns_error_on_file_exception(self):
        self.action.open_file.side_effect = IOError()
        self.assertEqual(self.action.run(), os.EX_IOERR)

    def test_it_finds_library(self):
        self.action.run()
        self.module.get_library.assert_called_once_with(self.ORG['name'])

    def test_it_calls_template_import_api(self):
        self.action.run()
        self.module.run_spinner_in_bg.assert_called_once_with(self.action.api.import_tpl, (self.LIBRARY['id'], None, self.open_file), message="")

    def test_it_closes_the_file(self):
        self.action.run()
        self.open_file.close.assert_called_once()

    def test_it_returns_status_ok(self):
        self.assertEqual(self.action.run(), os.EX_OK)
