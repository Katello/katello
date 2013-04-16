from katello.tests.core.action_test_utils import CLIOptionTestCase
from katello.client.core.system import Update


class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = Update()

    disallowed_options = [
        ('--content_view=view1', '--org=ACME'),
        ('--name=raspbi'),
        ('--name=raspbi', '--env=Dev'),
    ]

    allowed_options = [
        ('--org=ACME', '--name=raspbi'),
        ('--org=ACME', '--name=raspbi', '--content_view=view1'),
        ('--org=ACME', '--env=Dev', '--name=raspbi'),
        ('--org=ACME', '--name=raspbi', '--remove_content_view'),
        ('--org=ACME', '--name=raspbi', '--content_view_id=6')
    ]
