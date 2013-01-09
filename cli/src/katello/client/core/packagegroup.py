import os

from katello.client.api.repo import RepoAPI
from katello.client.core.base import BaseAction, Command
from katello.client.core.utils import system_exit
from katello.client.lib.utils.printer import batch_add_columns


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

        batch_add_columns(self.printer, {'id': _("ID")}, {'name': _("Name")}, {'description': _("Description")})

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
            system_exit(os.EX_DATAERR, _("Package group [%(groupid)s] not found in repo [%(repoid)s]") \
                % {'groupid':groupid, 'repoid':repoid})

        self.printer.set_header(_("Package Group Information"))
        batch_add_columns(self.printer, {'id': _("ID")}, {'name': _("Name")})
        batch_add_columns(self.printer, {'description': _("Description")}, \
            {'mandatory_package_names': _("Mandatory Package Names")}, \
            {'default_package_names': _("Default Package Names")}, \
            {'optional_package_names': _("Optional Package Names")}, \
            {'conditional_package_names': _("Conditional Package Names")}, multiline=True)

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

        self.printer.add_column('id', _("ID"))
        self.printer.add_column('name', _("Name"))

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
            system_exit(os.EX_DATAERR, _("Package group category [%(categoryId)s] not found in repo [%(repoid)s]") \
                % {'categoryId':categoryId, 'repoid':repoid})

        self.printer.set_header(_("Package Group Category Information"))
        batch_add_columns(self.printer, {'id': _("ID")}, {'name': _("Name")}, \
            {'packagegroupids': _("Package Group IDs")})

        self.printer.print_item(category)


class PackageGroup(Command):

    description = _('package group specific actions in the katello server')
