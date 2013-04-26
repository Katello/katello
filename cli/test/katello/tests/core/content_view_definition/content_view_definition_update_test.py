from katello.tests.core.action_test_utils import CLIOptionTestCase
from katello.client.core.content_view_definition import Update


class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = Update()

    disallowed_options = [
        ('--name=MyRHEL', ),
        ('--org=ACME_Corporation', ),
        ('--org=ACME_Corporation', '--label=Test', )
    ]

    allowed_options = [
        ('--org=ACME_Corporation', '--name=MyRHEL', '--new_name=Wat'),
        ('--org=ACME_Corporation', '--name=MyRHEL', '--description=Wat'),
        ('--org=ACME_Corporation', '--id=42', '--description=Wat')
    ]
