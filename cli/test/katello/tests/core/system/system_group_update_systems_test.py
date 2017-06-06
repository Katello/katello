from katello.tests.core.action_test_utils import CLIOptionTestCase

import katello.client.core.system_group
from katello.client.core.system_group import UpdateSystems


class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = UpdateSystems()

    disallowed_options = [
        ('--view=view1', '--org=ACME'),
        ('--name=raspbi'),
        ('--name=raspbi', '--env=Dev'),
    ]

    allowed_options = [
        ('--org=ACME', '--name=raspbi', '--env=Dev'),
        ('--org=ACME', '--name=raspbi', '--view_label=view1'),
        ('--org=ACME', '--name=raspbi', '--view=view1', '--env=Dev')
    ]


class SystemGroupUpdateSystemsTest(object):

    ORG = {"id": 1,
           "name": "ACME"
           }
    GROUP = {"id": 2,
             "name": "Test"
             }
    VIEW = {"id": 3,
            "name": "PlayerOfGames",
            "label": "POG"
            }
    ENV = {"id": 4,
           "name": "Staging"
           }

    OPTIONS = {
        'org': ORG["name"],
        'name': GROUP["name"],
        'view_label': VIEW['label'],
        'env': ENV['name']
    }

    def setUp(self):
        self.set_action(UpdateSystems())
        self.set_module(katello.client.core.system_groups)

        self.mock_options(self.OPTIONS)

        self.mock(self.module, 'get_content_view', self.VIEW)
        self.mock(self.module, 'get_environment', self.ENV)
        self.mock(self.module, 'get_system_group', self.GROUP)

    def test_it_calls_the_update_systems_api_with_ids(self):
        self.run_action()
        self.action.api.update_systems.assert_called_once_with(self.ORG["id"], self.GROUP["id"],
                                                               self.ENV['id'], self.VIEW["id"])

