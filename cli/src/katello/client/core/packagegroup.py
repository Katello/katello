import os

from katello.client.api.repo import RepoAPI
from katello.client.core.base import BaseAction, Command
from katello.client.core.utils import system_exit
from katello.client.utils.printer import batch_add_columns


class PackageGroupAction(BaseAction):

    def __init__(self):
        super(PackageGroupAction, self).__init__()
        self.api = RepoAPI()

class List(PackageGroupAction):

    description = _('list available package groups')

    def setup_parser(self, parser):
        parser.add_option("--repo_id", dest="repo_id",
                        help=_("repository ID, string value (required)"))

    def check_options(self, validator):
        validator.require('repo_id')

    def run(self):
        repoid = self.get_option('repo_id')
        groups = self.api.packagegroups(repoid)
        if not groups:
            system_exit(os.EX_DATAERR,
                        _("No package groups found in repo [%s]") % (repoid))
        self.printer.set_header(_("Package Group Information"))

        batch_add_columns(self.printer, 'id', 'name', 'description')

        self.printer.print_items(groups)

        return os.EX_OK


class Info(PackageGroupAction):

    name = "info"
    description = _('lookup information for a package group')

    def setup_parser(self, parser):
        parser.add_option("--repo_id", dest="repo_id",
                        help=_("repository ID, string value (required)"))
        parser.add_option("--id", dest="id",
                        help=_("package group ID, string value (required)"))

    def check_options(self, validator):
        validator.require(('repo_id', 'id'))

    def run(self):
        groupid = self.get_option('id')
        repoid = self.get_option('repo_id')

        group = self.api.packagegroup_by_id(repoid, groupid)
        if group == None:
            system_exit(os.EX_DATAERR, _("Package group [%s] not found in repo [%s]") % (groupid, repoid))

        self.printer.set_header(_("Package Group Information"))
        batch_add_columns(self.printer,
            'id', 'name')
        batch_add_columns(self.printer,
            'description', 'mandatory_package_names', 'default_package_names',
            'optional_package_names', 'conditional_package_names',
            multiline=True)

        self.printer.print_item(group)


class CategoryList(PackageGroupAction):

    description = _('list available package groups categories')

    def setup_parser(self, parser):
        parser.add_option("--repo_id", dest="repo_id",
                        help=_("repository ID, string value (required)"))

    def check_options(self, validator):
        validator.require('repo_id')

    def run(self):
        repoid = self.get_option('repo_id')
        groups = self.api.packagegroupcategories(repoid)
        if not groups:
            system_exit(os.EX_DATAERR,
                        _("No package group categories found in repo [%s]") % (repoid))
        self.printer.set_header(_("Package Group Cateogory Information"))

        self.printer.add_column('id')
        self.printer.add_column('name')

        self.printer.print_items(groups)

        return os.EX_OK


class CategoryInfo(PackageGroupAction):

    name = "info"
    description = _('lookup information for a package group')

    def setup_parser(self, parser):
        parser.add_option("--repo_id", dest="repo_id",
                        help=_("repository ID, string value (required)"))
        parser.add_option("--id", dest="id",
                        help=_("package group category ID, string value (required)"))

    def check_options(self, validator):
        validator.require(('repo_id', 'id'))

    def run(self):
        categoryId = self.get_option('id')
        repoid = self.get_option('repo_id')
        category = self.api.packagegroupcategory_by_id(repoid, categoryId)

        if category == None:
            system_exit(os.EX_DATAERR, _("Package group category [%s] not found in repo [%s]") % (categoryId, repoid))

        self.printer.set_header(_("Package Group Category Information"))
        batch_add_columns(self.printer, 'id', 'name', 'packagegroupids')

        self.printer.print_item(category)


class PackageGroup(Command):

    description = _('package group specific actions in the katello server')
