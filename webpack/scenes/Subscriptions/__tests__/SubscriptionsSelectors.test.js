import { testSelectorsSnapshotWithFixtures } from 'react-redux-test-utils';
import {
  selectSubscriptionsState,
  selectSearchQuery,
  selectDeleteModalOpened,
  selectDeleteButtonDisabled,
  selectSubscriptionsTasks,
  selectTaskModalOpened,
} from '../SubscriptionsSelectors';

const state = {
  katello: {
    subscriptions: {
      searchQuery: 'some-query',
      deleteModalOpened: false,
      taskModalOpened: false,
      deleteButtonDisabled: true,
      tasks: ['task1', 'task2'],
    },
  },
};

const fixtures = {
  'should select the subscriptions state': () => selectSubscriptionsState(state),
  'should select search-query': () => selectSearchQuery(state),
  'should select delete-modal-opened': () => selectDeleteModalOpened(state),
  'should select task-modal-opened': () => selectTaskModalOpened(state),
  'should select delete-button-disabled': () => selectDeleteButtonDisabled(state),
  'should select subscriptions tasks': () => selectSubscriptionsTasks(state),
};

describe('Subscriptions selectors', () => testSelectorsSnapshotWithFixtures(fixtures));
