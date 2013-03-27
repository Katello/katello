import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase
from katello.tests.core.activation_key import activation_key_data as key_data
from katello.tests.core.content_view_definition import content_view_definition_data as view_data
from katello.client.core.activation_key import Create

import katello.client.core.activation_key


class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = Create()

    disallowed_options = [
        ('--content_view=view1', '--org=ACME', '--environment=Dev'),
        ('--name=key1'),
        ('--org=ACME', '--name=key1')
    ]

    allowed_options = [
        ('--org=ACME', '--name=key1', '--env=Dev', ),
        ('--org=ACME', '--name=key1', '--env=Dev', '--content_view=view1', )
    ]


class ActivationKeyCreateTest(CLIActionTestCase):

    KEY = key_data.ACTIVATION_KEYS[0]
    VIEW = view_data.VIEWS[0]

    OPTIONS = {
        'name': KEY['name'],
        'org': "ACME",
        'env': "Dev",
        'view': VIEW['label']
    }

    def setUp(self):
        self.set_action(Create())
        self.set_module(katello.client.core.activation_key)

        self.mock_options(self.OPTIONS)
        self.mock(self.module, 'get_content_view', self.VIEW)
        self.mock(self.action.api, "create", self.KEY)
        self.mock(self.module, "get_environment", {"id": 1})

    def test_it_calls_get_content_view(self):
        self.run_action(os.EX_OK)
        self.module.get_content_view.assert_called_once_with(self.OPTIONS['org'], self.VIEW['label'])
