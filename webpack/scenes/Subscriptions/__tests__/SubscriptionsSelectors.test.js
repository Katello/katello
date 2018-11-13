import { testSelectorsSnapshotWithFixtures } from '../../../move_to_pf/test-utils/testHelpers';
import {
  selectSubscriptionsState,
  selectManifestModalOpened,
  selectDeleteModalOpened,
  selectSubscriptionsTasks,
} from '../SubscriptionsSelectors';

const state = {
  katello: {
    subscriptions: {
      manifestModalOpened: false,
      deleteModalOpened: false,
      tasks: ['task1', 'task2'],
    },
  },
};

const fixtures = {
  'should select the subscriptions state': () => selectSubscriptionsState(state),
  'should select manifest-modal-opened': () => selectManifestModalOpened(state),
  'should select delete-modal-opened': () => selectDeleteModalOpened(state),
  'should select subscriptions tasks': () => selectSubscriptionsTasks(state),
};

describe('Subscriptions selectors', () => testSelectorsSnapshotWithFixtures(fixtures));
