import { testSelectorsSnapshotWithFixtures } from 'react-redux-test-utils';
import {
  selectSubscriptionsState,
  selectSearchQuery,
  selectDeleteModalOpened,
  selectDeleteButtonDisabled,
  selectSubscriptionsTask,
  selectHasUpstreamConnection,
  selectActivePermissions,
} from '../SubscriptionsSelectors';

const state = {
  katello: {
    subscriptions: {
      searchQuery: 'some-query',
      deleteModalOpened: false,
      taskModalOpened: false,
      deleteButtonDisabled: true,
      hasUpstreamConnection: false,
      task: {},
      activePermissions: {
        can_import_manifest: true,
        can_delete_manifest: true,
        can_manage_subscription_allocations: true,
        can_edit_organizations: true,
        can_view_subscriptions: true,
      },
    },
  },
};

const fixtures = {
  'should select the subscriptions state': () => selectSubscriptionsState(state),
  'should select search-query': () => selectSearchQuery(state),
  'should select delete-modal-opened': () => selectDeleteModalOpened(state),
  'should select delete-button-disabled': () => selectDeleteButtonDisabled(state),
  'should select subscriptions task': () => selectSubscriptionsTask(state),
  'should select whether we have an upstream connection': () => selectHasUpstreamConnection(state),
  'should select active permissions': () => selectActivePermissions(state),
};

describe('Subscriptions selectors', () => testSelectorsSnapshotWithFixtures(fixtures));
