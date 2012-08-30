import unittest
import os
import __builtin__

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase
from katello.tests.core.organization import organization_data
from katello.tests.core.template import template_data

import katello.client.core.template
from katello.client.core.template import Import



class RequiredCLIOptionsTests(CLIOptionTestCase):
    #requires: organization, file

    action = Import()

    disallowed_options = [
        ('--file=/a/b/c/template.import', ),
        ('--org=ACME', ),
    ]

    allowed_options = [
        ('--org=ACME', '--file=/a/b/c/template.import'),
    ]



class TemplateImportTest(CLIActionTestCase):

    ORG = organization_data.ORGS[0]
    LIBRARY = organization_data.ENVS[0]
    TPL = template_data.TEMPLATES[0]

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

        self.mock(self, 'open_file')
        self.mock(self.open_file, 'close')
        self.open_file = self.mock(self.action, 'open_file', self.open_file).return_value
        self.mock(self.action.api, 'import_tpl', 'Import successfull')


    def test_it_opens_the_file(self):
        self.run_action()
        self.action.open_file.assert_called_once_with(self.OPTIONS['file'])

    def test_it_returns_error_on_file_exception(self):
        self.action.open_file.side_effect = IOError()
        self.run_action(os.EX_IOERR)

    def test_it_finds_library(self):
        self.run_action()
        self.module.get_library.assert_called_once_with(self.ORG['name'])

    def test_it_calls_template_import_api(self):
        self.run_action()
        self.module.run_spinner_in_bg.assert_called_once_with(self.action.api.import_tpl, (self.LIBRARY['id'], None, self.open_file), message="Importing template, please wait... ")

    def test_it_closes_the_file(self):
        self.run_action()
        self.open_file.close.assert_called_once()

    def test_it_returns_status_ok(self):
        self.run_action(os.EX_OK)
