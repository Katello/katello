import unittest
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase
from katello.tests.core.organization import organization_data
from katello.tests.core.template import template_data

import katello.client.core.template
from katello.client.core.template import List
from katello.client.api.utils import ApiDataError


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #requires: organization
    #optional: environment (defaults to Library)

    action = List()

    disallowed_options = [
        ('--environment=dev', ),
    ]

    allowed_options = [
        ('--org=ACME', ),
        ('--org=ACME', '--environment=dev'),
    ]



class TemplateListTest(CLIActionTestCase):

    ORG = organization_data.ORGS[0]
    ENV = organization_data.ENVS[0]

    OPTIONS = {
        'org': ORG['name'],
        'environment': ENV['name'],
    }

    def setUp(self):
        self.set_action(List())
        self.set_module(katello.client.core.template)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'templates', template_data.TEMPLATES)
        self.mock(self.module, 'get_environment', self.ENV)

    def test_it_finds_environment(self):
        self.run_action()
        self.module.get_environment.assert_called_once_with(self.ORG['name'], self.ENV['name'])

    def test_it_returns_error_when_environment_not_found(self):
        self.mock(self.module, 'get_environment').side_effect = ApiDataError
        self.run_action(os.EX_DATAERR)

    def test_it_calls_templates_api(self):
        self.run_action()
        self.action.api.templates.assert_called_once_with(self.ENV['id'])

    def test_it_prints_the_templates(self):
        self.run_action()
        self.action.printer.print_items.assert_called_once_with(template_data.TEMPLATES)
