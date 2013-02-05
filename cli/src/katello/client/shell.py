# -*- coding: utf-8 -*-
#
# Copyright (c) 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU Lesser General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (LGPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of LGPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/lgpl-2.0.txt.

import atexit
import logging
import os
import readline
import re
import sys
from cmd import Cmd
import ConfigParser

from katello.client.completion import Completion
from katello.client.config import Config, ConfigFileError
from katello.client.core.base import Command
from katello.client.lib.utils.encoding import encode_stream, stdout_origin

class KatelloShell(Cmd):

    # maximum length of history file
    HISTORY_LENGTH = 1024
    BUILTIN_COMMANDS = ("help", "quit", "exit")

    cmdqueue = []
    completekey = 'tab'
    stdout = sys.stdout

    # do nothing on an empty line
    emptyline = lambda self: None

    # pylint: disable=R0201
    @property
    def history_file(self):
        conf_dir = Config.USER_DIR
        try:
            if not os.path.isdir(conf_dir):
                os.mkdir(conf_dir, 0700)
        except OSError:
            logging.error('Could not create directory %s', conf_dir)
        return os.path.join(conf_dir, 'history')


    def __init__(self, admin_cli):
        # remove stdout stream encoding while in 'shell' mode, becuase this breaks readline
        # (autocompletion and shell history). In 'shell' mode the stdout
        # is encoded just for time necessary for command execution see precmd a postcmd

        sys.stdout = stdout_origin
        self.stdout_with_codec = encode_stream(sys.stdout, "utf-8")

        self.completion_matches = None
        Cmd.__init__(self)
        self.admin_cli = admin_cli
        self.completion = Completion(self.admin_cli)
        try:
            Config()
            self.prompt = Config.parser.get('shell', 'prompt') + ' '
        except (ConfigFileError, ConfigParser.Error):
            self.prompt = 'katello> '

        try:
            # don't split on hyphens during tab completion (important for completing parameters)
            newdelims = readline.get_completer_delims()
            newdelims = re.sub('-', '', newdelims)
            readline.set_completer_delims(newdelims)

            if (Config.parser.get('shell', 'nohistory').lower() != 'true'):
                self.__init_history()
        except ConfigParser.Error:
            pass
        self.__init_commands()


    def __init_history(self):
        try:
            readline.read_history_file(self.history_file)
            readline.set_history_length(self.HISTORY_LENGTH)
            # always write the history file on exit
            atexit.register(readline.write_history_file, self.history_file)
        except IOError:
            logging.error('Could not read history file')


    def __init_commands(self):
        # add commans to shell to avoid unknown syntax errors
        for cmd in self.admin_cli.get_command_names():
            setattr(self, "do_"+cmd, self.admin_cli.main)
        # add builtin commands into cli command - needed for correct completion
        for name in self.BUILTIN_COMMANDS:
            self.admin_cli.add_command(name, Command())
        # set exit aliases
        setattr(self, "do_quit", self.do_exit)
        setattr(self, "do_EOF", self.do_exit)
        setattr(self, "do_eof", self.do_exit)


    # pylint: disable=W0613
    def do_exit(self, args):
        self.__remove_last_history_item()
        sys.exit(0)


    def do_help(self, str_args):
        self.admin_cli.main("--help")


    def precmd(self, line):
        # turn on wrapper for encoding stdout
        sys.stdout = self.stdout_with_codec
        # preprocess the line
        line = line.strip()
        line = self.__history_preprocess(line)
        return line


    def postcmd(self, stop, line):
        # turn off wrapper for encoding stdout
        sys.stdout = stdout_origin
        # always stay in the command loop (we call sys.exit from exit commands)
        return False


    def __history_preprocess(self, line):
        # history search commands start with !
        if not line.startswith('!'):
            return line

        command = line.split()[0]
        if re.match('^!$', command):
            # single ! repeats last command
            new_line = self.__history_try_repeat_nth(-1)
        elif re.match('^!-?[0-9]+$', command):
            # !<int> repeats n-th command from history
            # negative numbers can be used for reversed indexing
            new_line = self.__history_try_repeat_nth(command[1:])
        else:
            # !<string> searches for last command starting with the string
            # and repeats it
            new_line = self.__history_try_search(command[1:])

        # remove the '!*' line from the history
        if new_line:
            self.__replace_last_history_item(new_line)
            print new_line
            return new_line
        return line

    @classmethod
    def __history_try_repeat_nth(cls, n):
        try:
            n = int(n)
            if n < 0:
                n = readline.get_current_history_length()+n
            return readline.get_history_item(n)
        except IOError:
            logging.warning('Could not read history file')
            return ''

    @classmethod
    def __history_try_search(cls, text):
        history_range = range(readline.get_current_history_length(), 1, -1)
        for i in history_range:
            item = readline.get_history_item(i)
            if item.startswith(text):
                return item
        return ''


    def parseline(self, line):
        """
        Parses a line to command and arguments.
        For our uses we copy name of the command to arguments so that
        the man command knows what subcommands to run.
        """
        cmd, arg, line = Cmd.parseline(self, line)
        if (cmd in self.admin_cli.get_command_names()) and (arg != None):
            arg = cmd + " " + arg
        return cmd, arg, line


    def complete(self, text, state):
        """
        Return the next possible completion for 'text'.
        """
        if state == 0:
            line = readline.get_line_buffer()
            self.completion_matches = self.completion.complete(line)

        try:
            return self.completion_matches[state]
        except IndexError:
            return None


    @classmethod
    def __remove_last_history_item(cls):
        last = readline.get_current_history_length() - 1
        if last >= 0:
            readline.remove_history_item(last)


    def __replace_last_history_item(self, replace_with):
        self.__remove_last_history_item()
        readline.add_history(replace_with)
