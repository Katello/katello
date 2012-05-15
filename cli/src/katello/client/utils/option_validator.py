# -*- coding: utf-8 -*-

# Copyright © 2010 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.

from gettext import gettext as _




class OptionValidator(object):

    def __init__(self, option_parser, options, arguments=None):
        self.opt_errors = []
        self.parser = option_parser
        self.options = options
        self.arguments = arguments


    def exists(self, opt_dest):
        """
        Check if option is present
        @type opt_dest: str
        @param opt_dest: option destination to check
        @return True if the option was set, otherwise False
        """
        return (not getattr(self.options, opt_dest) is None)


    def any_exist(self, opt_dests):
        """
        Check if any of options is present
        @type opt_dests: iterable(str)
        @param opt_dests: option destinations to check
        @return True if the any of the options was set, otherwise False
        """
        return any( self.exists(dest) for dest in opt_dests )


    def all_exist(self, opt_dests):
        """
        Check if all the options are present
        @type opt_dests: iterable(str)
        @param opt_dests: option destinations to check
        @return True if the all the options were set, otherwise False
        """
        return all( self.exists(dest) for dest in opt_dests )


    def require(self, opt_dests, message=None):
        """
        Check if all the options are present and add an error to a message
        stack if not.
        @type opt_dests: iterable(str)
        @param opt_dests: option destinations to check
        @type message: str
        @param message: custom error message
        """
        opt_dests = self.__ensure_iterable(opt_dests)
        for opt_dest in opt_dests:
            if not self.exists(opt_dest):
                flag = self.__get_option_string(opt_dest)
                if message:
                    self.add_option_error(message)
                else:
                    self.add_option_error(_('Option %s is required; please see --help') % flag)


    def mutually_exclude(self, *opt_dest_tuples):
        """
        Allows only one of option tuples to be present.
        @type opt_dest_tuples: iterable(str)
        @param opt_dest_tuples: option destinations to check
        """
        opt_dest_tuples = [self.__ensure_iterable(opt_dests) for opt_dests in opt_dest_tuples]

        for dest_tuple in opt_dest_tuples:
            if self.any_exist(dest_tuple):
                for other_dest_tuple in opt_dest_tuples:
                    if other_dest_tuple != dest_tuple:
                        self.reject(other_dest_tuple, colliding_opts=dest_tuple)
                return


    def reject(self, opt_dest, colliding_opts=None, message=None):
        """
        Add an option error if an option is present.
        @type opt_dest: iterable(str)
        @param opt_dest: option destinations to check
        @type colliding_opts: iterable(str)
        @param colliding_opts: option destinations that collide with the rejected
        ones. Used in error message.
        @type message: str
        @param message: custom error message
        """
        opt_dest = self.__ensure_iterable(opt_dest)
        colisions = self.__filter_existing(opt_dest)

        if colisions:
            flags = ', '.join(self.__get_option_strings(colisions))
            if message:
                self.add_option_error(message)
            elif colliding_opts:
                colliding_flags = ', '.join(self.__get_option_strings(colliding_opts))
                if len(colisions) > 1:
                    self.add_option_error(_('Options %s are colliding with %s; please see --help') % (flags, colliding_flags))
                else:
                    self.add_option_error(_('Option %s is colliding with %s; please see --help') % (flags, colliding_flags))
            else:
                if len(colisions) > 1:
                    self.add_option_error(_('Options %s can\'t be used in this command; please see --help') % flags)
                else:
                    self.add_option_error(_('Option %s can\'t be used in this command; please see --help') % flags)


    def require_all_or_none(self, opt_dests, message=None):
        """
        If one of the options is present, all are required.
        Otherwise add an error to a message stack.
        @type opt_dests: iterable(str)
        @param opt_dests: option destinations to check
        @type message: str
        @param message: custom error message
        """
        if self.any_exist(opt_dests):
            self.require(opt_dests, message)


    def require_one_of(self, opt_dests, message=None):
        """
        Check if one and only one of the options is present.
        Otherwise add an error to a message stack.
        @type opt_dests: iterable(str)
        @param opt_dests: option destinations to check
        @type message: str
        @param message: custom error message
        """
        if not len(self.__filter_existing(opt_dests)) == 1:
            if message:
                self.add_option_error(message)
            else:
                flags = self.__get_option_strings(opt_dests)
                self.add_option_error(_('Exactly one of %s is required; please see --help') % ', '.join(flags))
        return


    def require_at_most_one_of(self, opt_dests, message=None):
        """
        Add an option error if there is more then one of the options present.
        @type opt_dests: iterable(str)
        @param opt_dests: option destinations to check
        @type message: str
        @param message: custom error message
        """
        if self.any_exist(opt_dests):
            self.require_one_of(opt_dests, message)


    def require_at_least_one_of(self, opt_dests, message=None):
        """
        Add an option error if there is less then one of the options present.
        @type opt_dests: iterable(str)
        @param opt_dests: option destinations to check
        @type message: str
        @param message: custom error message
        """
        if self.any_exist(opt_dests):
            return

        if message:
            self.add_option_error(message)
        else:
            flags = self.__get_option_strings(opt_dests)
            self.add_option_error(_('At least one of %s is required; please see --help') % ', '.join(flags))


    def add_option_error(self, error_msg):
        """
        Add option error to the error stack
        @type error_msg: str
        @param error_msg: error message
        """
        self.opt_errors.append(error_msg)


    def __filter_existing(self, opt_dests):
        return [ dest for dest in opt_dests if self.exists(dest) ]


    def __get_option_string(self, opt_dest):
        opt = self.parser.get_option_by_dest(opt_dest)
        if not opt is None:
            flag = opt.get_opt_string()
        else:
            flag = '--' + opt_dest
        return flag


    def __get_option_strings(self, opt_dests):
        return [ self.__get_option_string(dest) for dest in opt_dests ]


    def __ensure_iterable(self, var):
        if not isinstance(var, (tuple, list)):
            return [var]
        else:
            return var