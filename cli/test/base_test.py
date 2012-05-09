from unittest import TestCase

from katello.client.core.base import Action
import os

class ActionTest(TestCase):

    def require_one_of_options_action_class(self):
        """
        Helper to setup fresh testing action for require_one_of_options
        """
        class TestAction(Action):
            def setup_parser(self):
                self.parser.add_option('--test1', dest='test1', action="store_true")
                self.parser.add_option('--test2', dest='test2', action="store_true")
                self.parser.add_option('--test3', dest='test3', action="store_true")

            def check_options(self):
                self.require_one_of_options('test1', 'test2', 'test3')

            def run(self):
                return os.EX_OK

        return TestAction

    def test_require_one_of_options(self):

        TestAction = self.require_one_of_options_action_class()
        test_action = TestAction()

        args = ['test', '--test1']
        result = test_action.main(args)
        self.assertEquals(result, os.EX_OK)

    def test_require_one_of_options_adds_error_on_no_option(self):

        TestAction = self.require_one_of_options_action_class()
        test_action = TestAction()

        args = ['test']
        result = test_action.main(args)
        self.assertEquals(result, 2) # optparser exitcode on error

    def test_require_one_of_options_adds_error_on_more_than_one_option(self):

        TestAction = self.require_one_of_options_action_class()
        test_action = TestAction()

        args = ['test', '--test1', '--test2']
        result = test_action.main(args)
        self.assertEquals(result, 2) # optparser exitcode on error
