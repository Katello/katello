import os
import time
import urlparse
from gettext import gettext as _

from katello.client import constants
from katello.client.core.utils import format_date
from katello.client.api.repo import RepoAPI
from katello.client.config import Config
from katello.client.core.base import Action, Command

Config()


class PackageGroupAction(Action):

    def __init__(self):
        super(PackageGroupAction, self).__init__()
        self.api = RepoAPI()

class List(PackageGroupAction):

    description = _('list available package groups')

    def setup_parser(self):
        self.parser.add_option("--repoid", dest="repoid",
                        help=_("repository id, string value (required)"))

    def check_options(self):
        self.require_option('repoid')

    def run(self):
        repoid = self.get_option('repoid')
        groups = self.api.packagegroups(repoid)
        if not groups:
            system_exit(os.EX_DATAERR,
                        _("No package groups found in repo [%s]") % (repoid))
        self.printer.setHeader(_("Package Group Information"))

        self.printer.addColumn('id')
        self.printer.addColumn('name')
        self.printer.addColumn('description')

        self.printer.printItems(groups.values())

        return os.EX_OK


class Info(PackageGroupAction):

    name = "info"
    description = _('lookup information for a package group')

    def setup_parser(self):
        self.parser.add_option("--repoid", dest="repoid",
                        help=_("repository id, string value (required)"))
        self.parser.add_option("--id", dest="id",
                        help=_("package group id, string value (required)"))

    def check_options(self):
        self.require_option('repoid')
        self.require_option('id')

    def run(self):
        groupid = self.get_option('id')
        repoid = self.get_option('repoid')
        groups = self.api.packagegroups(repoid)
        if not groups or groupid not in groups:
            system_exit(os.EX_DATAERR,
                        _("Package group [%s] not found in repo [%s]") %
                        (groupid, repoid))
        self.printer.setHeader(_("Package Group Information"))
        info = groups[groupid]
        self.printer.addColumn('id')
        self.printer.addColumn('name')
        self.printer.addColumn('description')
        self.printer.addColumn('mandatory_package_names')
        self.printer.addColumn('default_package_names')
        self.printer.addColumn('optional_package_names')
        self.printer.addColumn('conditional_package_names')

        self.printer.printItem(info)


class CategoryList(PackageGroupAction):

    description = _('list available package groups categories')

    def setup_parser(self):
        self.parser.add_option("--repoid", dest="repoid",
                        help=_("repository id, string value (required)"))

    def check_options(self):
        self.require_option('repoid')

    def run(self):
        repoid = self.get_option('repoid')
        groups = self.api.packagegroupcategories(repoid)
        if not groups:
            system_exit(os.EX_DATAERR,
                        _("No package group categories found in repo [%s]") % (repoid))
        self.printer.setHeader(_("Package Group Cateogory Information"))

        self.printer.addColumn('id')
        self.printer.addColumn('name')

        self.printer.printItems(groups.values())

        return os.EX_OK


class CategoryInfo(PackageGroupAction):

    name = "info"
    description = _('lookup information for a package group')

    def setup_parser(self):
        self.parser.add_option("--repoid", dest="repoid",
                        help=_("repository id, string value (required)"))
        self.parser.add_option("--id", dest="id",
                        help=_("package group category id, string value (required)"))

    def check_options(self):
        self.require_option('repoid')
        self.require_option('id')

    def run(self):
        categoryId = self.get_option('id')
        repoid = self.get_option('repoid')
        categories = self.api.packagegroupcategories(repoid)
        if not categories or categoryId not in categories:
            system_exit(os.EX_DATAERR,
                        _("Package group category [%s] not found in repo [%s]") %
                        (categoryId, repoid))
        self.printer.setHeader(_("Package Group Category Information"))
        info = categories[categoryId]
        self.printer.addColumn('id')
        self.printer.addColumn('name')
        self.printer.addColumn('packagegroupids')

        self.printer.printItem(info)


class PackageGroup(Command):

    description = _('package group specific actions in the katello server')
