import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase,\
        CLIActionTestCase

from katello.tests.core.organization import organization_data
from katello.tests.core.content_view_definition import content_view_definition_data

import katello.client.core.content_view_definition
from katello.client.core.content_view_definition import AddRemoveContentView
from katello.client.api.utils import ApiDataError


class RequiredCLIOptionsTest(object):

    disallowed_options = [
        ('--label=def1', '--view_id=view1'),
        ('--org=ACME', '--view_label=view1'),
        ('--org=ACME', '--label=def1')
    ]

    allowed_options = [
        ('--org=ACME', '--label=def1', '--view_name=view1')
    ]


class AddRequiredCLIOptionsTest(RequiredCLIOptionsTest, CLIOptionTestCase):
    action = AddRemoveContentView(True)


class RemoveRequiredCLIOptionsTest(RequiredCLIOptionsTest, CLIOptionTestCase):
    action = AddRemoveContentView(False)


class ContentDefinitionAddRemoveViewTest(object):

    ORG = organization_data.ORGS[0]
    DEF = content_view_definition_data.DEFS[0]
    VIEWS = content_view_definition_data.VIEWS
    VIEW = VIEWS[0]

    OPTIONS = {
        'org': ORG['name'],
        'label': DEF['label'],
        'view': VIEW['label']
    }

    addition = True

    def setUp(self):
        self.set_action(AddRemoveContentView(self.addition))
        self.set_module(katello.client.core.content_view_definition)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.module, 'get_cv_definition', self.DEF)
        self.mock(self.module, 'get_content_view', self.VIEW)
        self.mock(self.action.api, 'content_views', self.VIEWS)
        self.mock(self.action.api, 'update_content_views')

    def test_it_returns_with_error_if_no_def_was_found(self):
        self.mock(self.module, 'get_cv_definition').side_effect = ApiDataError()
        self.run_action(os.EX_DATAERR)

    def test_it_returns_with_error_if_view_was_not_found(self):
        self.mock(self.module, 'get_content_view').side_effect = ApiDataError()
        self.run_action(os.EX_DATAERR)

    def test_it_retrieves_all_definition_views(self):
        self.run_action()
        self.action.api.content_views.assert_called_once_with(self.DEF['id'])


class ContentDefinitionAddViewTest(ContentDefinitionAddRemoveViewTest, CLIActionTestCase):
    addition = True

    def test_it_calls_update_api(self):
        views = [v['id'] for v in self.VIEWS + [self.VIEW]]
        self.run_action()
        self.action.api.update_content_views.assert_called_once_with(self.DEF['id'], views)


class ContentDefinitionRemoveViewTest(ContentDefinitionAddRemoveViewTest, CLIActionTestCase):
    addition = False

    def test_it_calls_update_api(self):
        views = [v['id'] for v in self.VIEWS if v['name'] != self.VIEW['name']]
        self.run_action()
        self.action.api.update_content_views.assert_called_once_with(self.DEF['id'], views)
