from unittest import TestCase

from katello.client.core.base import Action
from katello.client.i18n_optparse import OptionParser
from katello.client.utils.option_validator import OptionValidator
from katello.tests.test_utils import ColoredAssertionError
import os

class OptionValidatorTestCase(TestCase):

    failureException = ColoredAssertionError

    def setup_parser(self, accepted_options):
        parser = OptionParser()
        for opt in accepted_options:
            parser.add_option('--'+opt, dest=opt, action="store_true")
        return parser

    def setup_validator(self, accepted_options, given_options):

        parser = self.setup_parser(accepted_options)
        (options, arguments) = parser.parse_args(given_options)

        return OptionValidator(parser, options, arguments)

    def error_count_msg(self, real_count, expected_count):
        return "validator error count was expected to be %s while in fact it was %s"\
            % (real_count, real_count)

    def return_value_msg(self, method_name, real_value, expected_value):
        return "validator method '%s' was expected to return %s while in fact it returned %s"\
            % (method_name, expected_value, real_value)

    def assert_error_count(self, validator, expected_count):
        msg = self.error_count_msg(len(validator.opt_errors), expected_count)
        self.assertEquals(len(validator.opt_errors), expected_count, msg=msg)


class ExistsTest(OptionValidatorTestCase):
    #def exists(self, opt_dest)

    def __test_method(self, given_options, tested_option, expected_return_value):
        validator = self.setup_validator(
            accepted_options = ('test1', 'test2', 'test3', 'test4'),
            given_options = given_options
        )
        returned_value = validator.exists(tested_option)
        message = self.return_value_msg("exists", returned_value, expected_return_value)
        self.assertEquals(returned_value, expected_return_value, msg=message)

    def test_the_option_exists(self):
        self.__test_method(['--test1', '--test2'], 'test1', True)

    def test_exists_returns_false_on_no_option(self):
        self.__test_method([], 'test1', False)

    def test_exists_returns_false_when_the_option_is_not_present(self):
        self.__test_method(['--test2', '--test3'], 'test1', False)



class AnyExistTest(OptionValidatorTestCase):
    #def any_exist(self, opt_dests)

    def __test_method(self, given_options, tested_options, expected_return_value):
        validator = self.setup_validator(
            accepted_options = ('test1', 'test2', 'test3', 'test4'),
            given_options = given_options
        )
        returned_value = validator.any_exist(tested_options)
        message = self.return_value_msg("any_exist", returned_value, expected_return_value)
        self.assertEquals(returned_value, expected_return_value, msg=message)


    def test_one_of_options_exists(self):
        self.__test_method(['--test1', '--test2'], ('test1', 'test2'), True)

    def test_any_exist_returns_false_no_option(self):
        self.__test_method([], ('test1', 'test2'), False)

    def test_exists_returns_false_when_the_option_is_not_present(self):
        self.__test_method(['--test1', '--test2'], ('test3', 'test4'), False)



class AllExistTest(OptionValidatorTestCase):
    #def all_exist(self, opt_dests)

    def __test_method(self, given_options, tested_options, expected_return_value):
        validator = self.setup_validator(
            accepted_options = ('test1', 'test2', 'test3', 'test4'),
            given_options = given_options
        )
        returned_value = validator.all_exist(tested_options)
        message = self.return_value_msg("all_exist", returned_value, expected_return_value)
        self.assertEquals(returned_value, expected_return_value, msg=message)

    def test_exists_returns_true_when_all_the_options_are_present(self):
        self.__test_method(['--test1', '--test2'], ('test1', 'test2'), True)

    def test_one_of_options_exists(self):
        self.__test_method(['--test1'], ('test1', 'test2'), False)

    def test_all_exist_returns_false_on_no_option(self):
        self.__test_method([], ('test1', 'test2'), False)

    def test_exists_returns_false_when_the_options_are_not_present(self):
        self.__test_method(['--test1', '--test2'], ('test3', 'test4'), False)


class RequireTest(OptionValidatorTestCase):
    #def require(self, opt_dests, message=None)

    def __test_method(self, given_options, tested_options, expected_error_cnt):
        validator = self.setup_validator(
            accepted_options = ('test1', 'test2', 'test3', 'test4'),
            given_options = given_options
        )
        validator.require(tested_options)
        self.assert_error_count(validator, expected_error_cnt)

    def test_require_one_option_that_is_present(self):
        self.__test_method(['--test1', '--test2'], 'test1', 0)

    def test_require_one_option_that_is_not_present(self):
        self.__test_method(['--test1', '--test2'], 'test3', 1)

    def test_require_options_that_are_present(self):
        self.__test_method(['--test1', '--test2'], ('test1', 'test2'), 0)

    def test_require_options_when_one_of_them_is_not_present(self):
        self.__test_method(['--test1', '--test2'], ('test1', 'test3'), 1)

    def test_require_options_when_no_option_given(self):
        self.__test_method([], ('test1', 'test3'), 2)


class MutuallyExcludeTest(OptionValidatorTestCase):
    #def mutually_exclude(self, *opt_dest_tuples)

    def __test_method(self, given_options, tested_option_tuples, expected_error_cnt):
        validator = self.setup_validator(
            accepted_options = ('test1', 'test2', 'test3', 'test4'),
            given_options = given_options
        )
        validator.mutually_exclude(*tested_option_tuples)
        self.assert_error_count(validator, expected_error_cnt)

    def test_options_are_exclusive(self):
        self.__test_method(['--test1', '--test3'], (('test1', ), ('test2', )), 0)

    def test_none_of_the_options_is_present(self):
        self.__test_method(['--test3', '--test4'], (('test1', ), ('test2', )), 0)

    def test_options_are_not_exclusive(self):
        self.__test_method(['--test1', '--test2'], (('test1', ), ('test2', )), 1)


class RejectTest(OptionValidatorTestCase):
    #def reject(self, opt_dest, colliding_opts=None, message=None)

    def __test_method(self, given_options, tested_options, expected_error_cnt):
        validator = self.setup_validator(
            accepted_options = ('test1', 'test2', 'test3', 'test4'),
            given_options = given_options
        )
        validator.reject(tested_options)

        self.assert_error_count(validator, expected_error_cnt)

    def test_reject_one_option_that_is_not_present(self):
        self.__test_method(['--test1', '--test2'], 'test3', 0)

    def test_reject_one_options_that_are_not_present(self):
        self.__test_method(['--test1', '--test2'], ('test3', 'test4'), 0)

    def test_reject_one_option_that_is_present(self):
        self.__test_method(['--test1', '--test2'], 'test1', 1)

    def test_reject_one_options_that_are_present(self):
        self.__test_method(['--test1', '--test2'], ('test1', 'test2'), 1)


class RequireAllOrNoneTest(OptionValidatorTestCase):
    #def require_all_or_none(self, opt_dests, message=None)

    def __test_method(self, given_options, tested_options, expected_error_cnt):
        validator = self.setup_validator(
            accepted_options = ('test1', 'test2', 'test3', 'test4'),
            given_options = given_options
        )
        validator.require_all_or_none(tested_options)
        self.assert_error_count(validator, expected_error_cnt)

    def test_with_no_options(self):
        self.__test_method([], ('test1', 'test2'), 0)

    def test_with_all_the_options_present(self):
        self.__test_method(['--test1', '--test2'], ('test1', 'test2'), 0)

    def test_with_none_of_the_options_present(self):
        self.__test_method(['--test1', '--test2'], ('test3', 'test4'), 0)

    def test_with_only_one_of_the_options_present(self):
        self.__test_method(['--test1'], ('test1', 'test2'), 1)


class RequireOneOfTest(OptionValidatorTestCase):
    #def require_one_of(self, opt_dests, message=None)

    def __test_method(self, given_options, tested_options, expected_error_cnt):
        validator = self.setup_validator(
            accepted_options = ('test1', 'test2', 'test3', 'test4'),
            given_options = given_options
        )
        validator.require_one_of(tested_options)
        self.assert_error_count(validator, expected_error_cnt)

    def test_adds_error_on_no_options(self):
        self.__test_method([], ('test1', 'test2'), 1)

    def test_adds_error_when_none_of_the_options_is_present(self):
        self.__test_method(['--test3'], ('test1', 'test2'), 1)

    def test_adds_error_when_more_than_one_options_is_present(self):
        self.__test_method(['--test1', '--test2', '--test3'], ('test1', 'test2'), 1)

    def test_when_one_of_the_options_is_present(self):
        self.__test_method(['--test1'], ('test1', 'test2'), 0)


class RequireAtMostOneOfTest(OptionValidatorTestCase):
    #def require_at_most_one_of(self, opt_dests, message=None)

    def __test_method(self, given_options, tested_options, expected_error_cnt):
        validator = self.setup_validator(
            accepted_options = ('test1', 'test2', 'test3', 'test4'),
            given_options = given_options
        )
        validator.require_at_most_one_of(tested_options)
        self.assert_error_count(validator, expected_error_cnt)

    def test_on_no_options(self):
        self.__test_method([], ('test1', 'test2'), 0)

    def test_when_none_of_the_options_is_present(self):
        self.__test_method(['--test3'], ('test1', 'test2'), 0)

    def test_when_one_of_the_options_is_present(self):
        self.__test_method(['--test1'], ('test1', 'test2'), 0)

    def test_adds_error_when_more_than_one_options_is_present(self):
        self.__test_method(['--test1', '--test2', '--test3'], ('test1', 'test2'), 1)


class RequireAtLeastOneOfTest(OptionValidatorTestCase):
    #def require_at_least_one_of(self, opt_dests, message=None)

    def __test_method(self, given_options, tested_options, expected_error_cnt):
        validator = self.setup_validator(
            accepted_options = ('test1', 'test2', 'test3', 'test4'),
            given_options = given_options
        )
        validator.require_at_least_one_of(tested_options)
        self.assert_error_count(validator, expected_error_cnt)

    def test_adds_error_on_no_options(self):
        self.__test_method([], ('test1', 'test2'), 1)

    def test_adds_error_when_none_of_the_options_is_present(self):
        self.__test_method(['--test3'], ('test1', 'test2'), 1)

    def test_when_one_of_the_options_is_present(self):
        self.__test_method(['--test1'], ('test1', 'test2'), 0)

    def test_when_more_than_one_options_is_present(self):
        self.__test_method(['--test1', '--test2', '--test3'], ('test1', 'test2'), 0)


class AddOptionErrorTest(OptionValidatorTestCase):
    #def add_option_error(self, error_msg)

    def test_there_are_no_errors_on_new_validator(self):
        validator = self.setup_validator(
            accepted_options = ('test1', ),
            given_options = []
        )
        self.assertEquals(len(validator.opt_errors), 0)

    def test_it_adds_error(self):
        validator = self.setup_validator(
            accepted_options = ('test1', ),
            given_options = []
        )
        validator.add_option_error("Error!")
        self.assertEquals(len(validator.opt_errors), 1)
