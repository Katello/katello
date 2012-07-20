from katello.tests.core.action_test_utils import CLIOptionTestCase
from katello.client.core.repo import Create

class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = Create()

    disallowed_options = [
        ('--name=repo1', '--url=http://localhost', '--product=product1'),
        ('--org=ACME', '--name=repo1', '--url=http://localhost'),
        ('--org=ACME', '--url=http://localhost', '--product=product1'),
        ('--org=ACME', '--name=repo1', '--product=product1')
    ]

    allowed_options = [
        ('--org=ACME', '--name=repo1', '--url=http://localhost', '--product=product1'),
        ('--org=ACME', '--name=repo1', '--url=https://localhost', '--product=product1'),
        ('--org=ACME', '--name=repo1', '--url=ftp://localhost', '--product=product1'),
        ('--org=ACME', '--name=repo1', '--url=file:///a/b/c/', '--product=product1')
    ]


