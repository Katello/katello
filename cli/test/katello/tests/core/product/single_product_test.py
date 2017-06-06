import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase

import katello.client.core.product
from katello.client.core.product import SingleProductAction



class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = SingleProductAction()

    disallowed_options = [
        ('--name=product_1', ),
        ('--org=ACME', ),
    ]

    allowed_options = [
        ('--org=ACME', '--name=product_1'),
    ]
