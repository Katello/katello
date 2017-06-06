import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase

import katello.client.core.content_view
from katello.client.core.content_view import Info


class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = Info()

    disallowed_options = [
        ('--name=view1', '--org=ACME', '--id=1', ),
        ('--name=view1', '--org=ACME', '--label=view1', ),
        ('--org=ACME', ),
        ('--org=ACME', '--env=Dev', )
    ]

    allowed_options = [
        ('--org=ACME', '--id=1', ),
        ('--name=view1', '--org=ACME', ),
        ('--label=view1', '--org=ACME', )
    ]
