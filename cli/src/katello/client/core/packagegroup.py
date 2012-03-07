import os
from gettext import gettext as _

from katello.client.api.repo import RepoAPI
from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.core.utils import system_exit

Config()


class PackageGroupAction(Action):

    def __init__(self):
        super(PackageGroupAction, self).__init__()
        self.api = RepoAPI()

class List(PackageGroupAction):

    description = _('list available package groups')

    def setup_parser(self):
        self.parser.add_option("--repo_id", dest="repo_id",
                        help=_("repository id, string value (required)"))

    def check_options(self):
        self.require_option('repo_id')

    def run(self):
        repoid = self.get_option('repo_id')
        groups = self.api.packagegroups(repoid)
        if not groups:
            system_exit(os.EX_DATAERR,
                        _("No package groups found in repo [%s]") % (repoid))
        self.printer.setHeader(_("Package Group Information"))

        self.printer.addColumn('id')
        self.printer.addColumn('name')
        self.printer.addColumn('description')

        self.printer.printItems(groups)

        return os.EX_OK


class Info(PackageGroupAction):

    name = "info"
    description = _('lookup information for a package group')

    def setup_parser(self):
        self.parser.add_option("--repo_id", dest="repo_id",
                        help=_("repository id, string value (required)"))
        self.parser.add_option("--id", dest="id",
                        help=_("package group id, string value (required)"))

    def check_options(self):
        self.require_option('repo_id')
        self.require_option('id')

    def run(self):
        groupid = self.get_option('id')
        repoid = self.get_option('repo_id')

        group = self.api.packagegroup_by_id(repoid, groupid)
        if group == None:
            system_exit(os.EX_DATAERR, _("Package group [%s] not found in repo [%s]") % (groupid, repoid))

        group['conditional_package_names'] = [name+": "+required_package  for name, required_package in group['conditional_package_names'].items()]

        self.printer.setHeader(_("Package Group Information"))
        self.printer.addColumn('id')
        self.printer.addColumn('name')
        self.printer.addColumn('description', multiline=True)
        self.printer.addColumn('mandatory_package_names', multiline=True)
        self.printer.addColumn('default_package_names', multiline=True)
        self.printer.addColumn('optional_package_names', multiline=True)
        self.printer.addColumn('conditional_package_names', multiline=True)

        self.printer.printItem(group)


class CategoryList(PackageGroupAction):

    description = _('list available package groups categories')

    def setup_parser(self):
        self.parser.add_option("--repo_id", dest="repo_id",
                        help=_("repository id, string value (required)"))

    def check_options(self):
        self.require_option('repo_id')

    def run(self):
        repoid = self.get_option('repo_id')
        groups = self.api.packagegroupcategories(repoid)
        if not groups:
            system_exit(os.EX_DATAERR,
                        _("No package group categories found in repo [%s]") % (repoid))
        self.printer.setHeader(_("Package Group Cateogory Information"))

        self.printer.addColumn('id')
        self.printer.addColumn('name')

        self.printer.printItems(groups)

        return os.EX_OK


class CategoryInfo(PackageGroupAction):

    name = "info"
    description = _('lookup information for a package group')

    def setup_parser(self):
        self.parser.add_option("--repo_id", dest="repo_id",
                        help=_("repository id, string value (required)"))
        self.parser.add_option("--id", dest="id",
                        help=_("package group category id, string value (required)"))

    def check_options(self):
        self.require_option('repo_id')
        self.require_option('id')

    def run(self):
        categoryId = self.get_option('id')
        repoid = self.get_option('repo_id')
        category = self.api.packagegroupcategory_by_id(repoid, categoryId)

        if category == None:
            system_exit(os.EX_DATAERR, _("Package group category [%s] not found in repo [%s]") % (categoryId, repoid))

        self.printer.setHeader(_("Package Group Category Information"))
        self.printer.addColumn('id')
        self.printer.addColumn('name')
        self.printer.addColumn('packagegroupids')

        self.printer.printItem(category)


class PackageGroup(Command):

    description = _('package group specific actions in the katello server')
