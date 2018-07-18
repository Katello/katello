import { testComponentSnapshotsWithFixtures } from '../../../move_to_pf/test-utils/testHelpers';

import { task } from '../../TasksMonitor/__tests__/TasksMonitor.fixtures';
import { successState as subscriptions } from './subscriptions.fixtures';
import SubscriptionsPage from '../SubscriptionsPage';

const createRequiredProps = () => ({
  subscriptions,
  loadSubscriptions: jest.fn(),
  updateQuantity: jest.fn(),
  startMonitoringManifestTasks: jest.fn(),
  stopMonitoringManifestTasks: jest.fn(),
  runMonitorManifestTasksManually: jest.fn(),
  loadSetting: jest.fn(),
  deleteSubscriptions: jest.fn(),
  exportSubscriptionsCsv: jest.fn(),
  openManageManifestModal: jest.fn(),
  closeManageManifestModal: jest.fn(),
  openDeleteModal: jest.fn(),
  closeDeleteModal: jest.fn(),
  disableDeleteButton: jest.fn(),
  enableDeleteButton: jest.fn(),
  updateSearchQuery: jest.fn(),
});

const fixtures = {
  'renders SubscriptionsPage': {
    ...createRequiredProps(),
  },
  'renders SubscriptionsPage with task in progress': {
    ...createRequiredProps(),
    hasTaskInProgress: true,
    currentManifestTask: task,
  },
  'renders SubscriptionsPage with manifest modal opened': {
    ...createRequiredProps(),
    manifestModalOpened: true,
  },
  'renders SubscriptionsPage with delete modal opened': {
    ...createRequiredProps(),
    deleteModalOpened: true,
  },
  'renders SubscriptionsPage with manifest actions disabled': {
    ...createRequiredProps(),
    manifestActionsDisabled: true,
    manifestActionsDisabledReason: 'some reason',
  },
  'renders SubscriptionsPage with delete button disabled': {
    ...createRequiredProps(),
    deleteButtonDisabled: true,
    deleteButtonDisabledReason: 'some reason',
  },
};

describe('subscriptions page', () => testComponentSnapshotsWithFixtures(SubscriptionsPage, fixtures));
