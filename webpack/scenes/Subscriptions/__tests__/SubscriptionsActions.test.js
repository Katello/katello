import { testActionSnapshotWithFixtures } from '../../../move_to_pf/test-utils/testHelpers';
import api, { orgId } from '../../../services/api';
import { apiError } from '../../../move_to_foreman/common/helpers';
import { filterRHSubscriptions } from '../SubscriptionHelpers';
import {
  startMonitoringTasks,
  stopMonitoringTasks,
  runMonitorLifecycle,
} from '../../TasksMonitor/TasksMonitorActions';
import { selectIsMonitorActive } from '../../TasksMonitor/TasksMonitorSelectors';

import { monitor } from '../../TasksMonitor/__tests__/TasksMonitor.fixtures';
import {
  loadSubscriptions,
  updateQuantity,
  loadAvailableQuantities,
  runMonitorManifestTasksManually,
  stopMonitoringManifestTasks,
  startMonitoringManifestTasks,
  createSubscriptionParams,
  deleteSubscriptions,
  exportSubscriptionsCsv,
  openManageManifestModal,
  closeManageManifestModal,
  openDeleteModal,
  closeDeleteModal,
  disableDeleteButton,
  enableDeleteButton,
  updateSearchQuery,
} from '../SubscriptionActions';

const noop = () => null;

const params = {
  ...monitor.params,
  search: 'some-search',
};

jest.mock('../../../services/api');
jest.mock('../../../move_to_foreman/common/helpers');
jest.mock('../SubscriptionHelpers');
jest.mock('../../TasksMonitor/TasksMonitorActions');
jest.mock('../../TasksMonitor/TasksMonitorSelectors');

const fixtures = {
  'should load subscriptions and success': {
    action: () => loadSubscriptions(params),
    test: () => {
      expect(api.get.mock.calls).toMatchSnapshot();
      expect(apiError).not.toHaveBeenCalled();
    },
  },
  'should load subscriptions and fail': () => (dispatch) => {
    api.get.mockImplementation(async () => {
      throw new Error('some-error');
    });

    return loadSubscriptions(params)(dispatch);
  },
  'should update quantity and success': {
    action: () => updateQuantity(),
    test: () => expect(api.put.mock.calls).toMatchSnapshot(),
  },
  'should update quantity and fail': () => {
    api.put.mockImplementation(async () => {
      throw new Error('some-error');
    });

    return updateQuantity();
  },
  'should load available quantities and success': {
    action: () => loadAvailableQuantities(params),
    test: () => expect(api.get.mock.calls).toMatchSnapshot(),
  },
  'should load available quantities and fail': () => {
    api.get.mockImplementation(async () => {
      throw new Error('some-error');
    });

    return loadAvailableQuantities(params);
  },
  'should run monitor manifest tasks manually': () => runMonitorManifestTasksManually(),
  'should stop monitoring manifest tasks': () => stopMonitoringManifestTasks(),
  'should start monitoring manifest tasks': () => dispatch => startMonitoringManifestTasks()(dispatch, noop),
  'should not start monitoring manifest tasks if its already monitoring': () => (dispatch) => {
    selectIsMonitorActive.mockImplementation(() => true);

    return startMonitoringManifestTasks()(dispatch, noop);
  },
  'should create subscription params': () => createSubscriptionParams(params),
  'should delete subscriptions and success': {
    action: () => deleteSubscriptions(['1', '2', '3']),
    test: () => expect(api.delete.mock.calls).toMatchSnapshot(),
  },
  'should delete subscriptions and fail': {
    action: () => (dispatch) => {
      api.delete.mockImplementation(async () => {
        throw new Error('some-error');
      });
      return deleteSubscriptions(['1', '2', '3'])(dispatch);
    },
    test: () => expect(api.delete.mock.calls).toMatchSnapshot(),
  },
  'should export subscriptions csv': {
    action: () => exportSubscriptionsCsv('some search query'),
    test: () => expect(api.open.mock.calls).toMatchSnapshot(),
  },
  'should open manage manifest modal': () => openManageManifestModal(),
  'should close manage manifest modal': () => closeManageManifestModal(),
  'should open delete modal': () => openDeleteModal(),
  'should close delete modal': () => closeDeleteModal(),
  'should disable delete button': () => disableDeleteButton(),
  'should enable delete button': () => enableDeleteButton(),
  'should update search query': () => updateSearchQuery('some search query'),
};

describe('Subscriptions actions', () => {
  beforeEach(() => {
    orgId.mockImplementation(() => 'some-org-id');
    api.get.mockImplementation(async () => ({
      data: {
        results: [{ id: 'some-id' }],
      },
    }));
    api.put.mockImplementation(async () => ({ data: 'some-data' }));
    api.delete.mockImplementation(async () => ({ data: 'some-data' }));
    api.open.mockImplementation(() => ({ data: 'some-data' }));
    filterRHSubscriptions.mockImplementation(subscriptions => subscriptions);
    apiError.mockImplementation((actionType, result) => ({
      type: actionType,
      payload: { result },
    }));
    runMonitorLifecycle.mockImplementation(id => `runMonitorLifecycle(${id})`);
    stopMonitoringTasks.mockImplementation(id => `stopMonitoringTasks(${id})`);
    startMonitoringTasks.mockImplementation(payload => ({
      type: 'startMonitoringTasks',
      payload,
    }));
    selectIsMonitorActive.mockImplementation(() => false);
  });
  afterEach(() => {
    jest.useRealTimers();
    jest.resetAllMocks();
    jest.restoreAllMocks();
    jest.resetModules();
  });

  testActionSnapshotWithFixtures(fixtures);
});
