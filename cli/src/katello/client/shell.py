#
# Licensed under the GNU General Public License Version 3
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# Copyright 2010 Aron Parsons <aron@redhat.com>
#

# NOTE: the 'self' variable is an instance of SpacewalkShell

import atexit
import logging
import os
import readline
import re
import sys
from cmd import Cmd

from katello.client.config import Config
from katello.client.core.utils import parse_tokens

Config()

class KatelloShell(Cmd):

    # maximum length of history file
    HISTORY_LENGTH = 1024

    cmdqueue = []
    completekey = 'tab'
    stdout = sys.stdout
    current_line = ''

    # do nothing on an empty line
    emptyline = lambda self: None

    def __init__(self, admin_cli):
        self.session = ''
        self.username = ''
        self.server = ''
        self.admin_cli = admin_cli

        try:
            self.prompt = Config.parser.get('shell', 'prompt') + ' '
        except:
            self.prompt = 'katello> '

        self.conf_dir = Config.USER_DIR

        try:
            if not os.path.isdir(self.conf_dir):
                os.mkdir(self.conf_dir, 0700)
        except OSError:
            logging.error('Could not create directory %s' % self.conf_dir)

        self.history_file = os.path.join(self.conf_dir, 'history')

        try:
            # don't split on hyphens during tab completion (important for completing parameters)
            newdelims = readline.get_completer_delims()
            newdelims = re.sub('-', '', newdelims)
            readline.set_completer_delims(newdelims)


            if (Config.parser.get('shell', 'nohistory').lower() != 'true'):
                try:
                    if os.path.isfile(self.history_file):
                        readline.read_history_file(self.history_file)

                    readline.set_history_length(self.HISTORY_LENGTH)

                    # always write the history file on exit
                    atexit.register(readline.write_history_file,
                                    self.history_file)
                except IOError:
                    logging.error('Could not read history file')
        except Exception:
            pass

        for cmd in admin_cli.command_names():
            setattr(self, "do_" + cmd, self.admin_cli.main)

    def do_quit(self, args):
        sys.exit(0)

    def do_exit(self, args):
        sys.exit(0)

    # handle commands that exit the shell
    def precmd(self, line):
        # remove leading/trailing whitespace
        line = re.sub('^\s+|\s+$', '', line)

        # don't do anything on empty lines
        if line == '':
            return ''

        # terminate the shell
        if re.match('quit|exit|eof', line, re.I):
            return "quit"

        line  = line.strip()
        parts = parse_tokens(line)


        if len(parts):
            command = parts[0]
        else:
            return ''

        if len(parts[1:]):
            args = ' '.join(parts[1:])
        else:
            args = ''

        # print the help message if the user passes '--help'
        line_parts = line.split("\"")
        for i in range(0, len(line_parts), 2):
            if re.search('--help', line_parts[i]) or re.search('-h', line_parts[i]):
                return 'help %s' % line

        # should we look for an item in the history?
        if command[0] != '!' or len(command) < 2:
            return line

        # remove the '!*' line from the history
        self.remove_last_history_item()

        history_match = False

        if command[1] == '!':
            # repeat the last command
            line = readline.get_history_item(readline.get_current_history_length())
            if line:
                history_match = True
            else:
                logging.warning('%s: event not found' % command)
                return ''

        # attempt to find a numbered history item
        if not history_match:
            try:
                number = int(command[1:])
                line = readline.get_history_item(number)
                if line:
                    history_match = True
            except IndexError:
                pass
            except ValueError:
                pass

        # attempt to match the beginning of the string with a history item
        if not history_match:
            history_range = range(1, readline.get_current_history_length())
            history_range.reverse()

            for i in history_range:
                item = readline.get_history_item(i)
                if re.match(command[1:], item):
                    line = item
                    history_match = True
                    break

        # append the arguments to the substituted command
        if history_match:

            # terminate the shell
            if re.match('quit|exit|eof', line, re.I):
                print line
                return "quit"

            line += ' %s' % args

            readline.add_history(line)
            print line
            return line
        else:
            logging.warning('%s: event not found' % command)
            return ''

    def parseline(self, line):
        cmd, arg, line = Cmd.parseline(self, line)
        if (cmd in self.admin_cli.command_names()) and (arg != None):
            arg = cmd + " " + arg
        return cmd, arg, line

    def postcmd(self, stop, line):
        if stop:
            return (line == "quit")
        else:
            return stop

    def do_help(self, strArgs):
        if strArgs:
            args = strArgs.split()
            cmd = self.admin_cli.get_command(args[0])
            if not cmd:
                print("Invalid Command %s") % args[0]
                return

            if len(args) > 1:
                cmd.main(args[1]+" --help")
            else:
                cmd.main("--help")

        else:
            self.admin_cli.main("--help")

    def completeparams(self, text, line, *ignored):
        parts = parse_tokens(line)
        cmdName    = parts[0]
        actionName = parts[1]
        action = self.admin_cli.get_command(cmdName).get_action(actionName)

        params = action.parser.get_long_options()

        return [a for a in params if a.startswith(text)]

    def completecommands(self, text, line, *ignored):
        cmdName = line.split()[0]
        actions = self.admin_cli.get_command(cmdName).action_names()
        return [a for a in actions if a.startswith(text)]

    def completenames(self, text, *ignored):
        commands = self.admin_cli.command_names() + ["help", "quit", "exit"]
        return [a for a in commands if a.startswith(text)]


    def complete(self, text, state):
        """Return the next possible completion for 'text'.

        If a command has not been entered, then complete against command list.
        Otherwise try to call complete_<command> to get list of completions.
        """
        if state == 0:
            origline = readline.get_line_buffer()
            line = origline.lstrip()
            stripped = len(origline) - len(line)
            begidx = readline.get_begidx() - stripped
            endidx = readline.get_endidx() - stripped

            wordCnt = len(line[:begidx].split())

            if wordCnt <= 0:
                self.completion_matches = self.completenames(text, line, begidx, endidx)
            elif wordCnt == 1:
                self.completion_matches = self.completecommands(text, line, begidx, endidx)
            else:
                self.completion_matches = self.completeparams(text, line, begidx, endidx)

        try:
            return self.completion_matches[state]
        except IndexError:
            return None


    def remove_last_history_item(self):
        last = readline.get_current_history_length() - 1

        if last >= 0:
            readline.remove_history_item(last)
