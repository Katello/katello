import unittest
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.template
from katello.client.core.template import Info
from katello.client.api.utils import ApiDataError


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #requires: organization, name
    #optional: environment (defaults to Library)

    action = Info()

    disallowed_options = [
        ('--environment=dev', '--name=template_1'),
        ('--environment=dev', '--org=ACME'),
    ]

    allowed_options = [
        ('--org=ACME', '--name=template_1'),
        ('--org=ACME', '--environment=dev', '--name=template_1'),
    ]



class TemplateInfoTest(CLIActionTestCase):

    ORG = test_data.ORGS[0]
    ENV = test_data.ENVS[0]
    TPL = test_data.TEMPLATES[0]

    OPTIONS = {
        'org': ORG['name'],
        'env': ENV['name'],
        'name': TPL['name'],
    }

    def setUp(self):
        self.set_action(Info())
        self.set_module(katello.client.core.template)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.module, 'get_template', self.TPL)

    def test_it_finds_the_template(self):
        self.run_action()
        self.module.get_template.assert_called_once_with(self.ORG['name'], self.ENV['name'], self.TPL['name'])

    def test_it_returns_error_when_template_not_found(self):
        self.mock(self.module, 'get_template').side_effect = ApiDataError
        self.run_action(os.EX_DATAERR)

    def test_it_returns_success_when_template_found(self):
        self.run_action(os.EX_OK)

    def test_it_prints_the_templates(self):
        self.run_action()
        self.action.printer.print_items.assert_called_once()
