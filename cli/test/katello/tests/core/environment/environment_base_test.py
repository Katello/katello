import os

from katello.tests.core.action_test_utils import CLIActionTestCase
from katello.tests.core.environment.environment_data import ENVS 

import katello.client.core.environment

class EnvironmentBaseTest(CLIActionTestCase):

    ENVS = ENVS
    DEV = ENVS[0]
    LIBRARY = ENVS[1]
    ENV = ENVS[0]
    ENV_NAME = ENV["name"]
    OPTIONS = None


