from unittest import TestCase
from mock import Mock


from katello.client.core.base import NewStyleCommand



class AddSubcommandTest(TestCase):

    def setUp(self):
        self.cmd = NewStyleCommand()
        self.sub_cmd_1 = NewStyleCommand()
        self.sub_cmd_2 = NewStyleCommand()

        self.cmd.add_subcommand("sub_cmd_1", self.sub_cmd_1)
        self.cmd.add_subcommand("sub_cmd_2", self.sub_cmd_2)
        pass

    def test_it_returns_subcmd_count(self):
        self.assertTrue(len(self.cmd.get_subcommand_names()) == 2)

    def test_it_returns_subcmd_names(self):
        self.assertTrue("sub_cmd_1" in self.cmd.get_subcommand_names())
        self.assertTrue("sub_cmd_2" in self.cmd.get_subcommand_names())
        self.assertFalse("sub_cmd_3" in self.cmd.get_subcommand_names())

    def test_it_finds_subcmd(self):
        self.assertTrue(self.cmd.get_subcommand("sub_cmd_1") == self.sub_cmd_1)

    def test_it_raises_exception_when_subcmd_not_noud(self):
        self.assertRaises(Exception, self.cmd.get_subcommand("unknown_sub_cmd"))