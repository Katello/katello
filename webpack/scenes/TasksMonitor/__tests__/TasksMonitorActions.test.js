import { testActionSnapshotWithFixtures } from '../../../move_to_pf/test-utils/testHelpers';
import { foremanTasksApi as api } from '../../../services/api';
import { selectMonitor, selectIsMonitorActive } from '../TasksMonitorSelectors';

import { monitor } from './TasksMonitor.fixtures';
import { stopMonitoringTasks, startMonitoringTasks, runMonitorLifecycle } from '../TasksMonitorActions';

jest.mock('../../../services/api');
jest.mock('../TasksMonitorSelectors');

const noop = () => null;

const fixtures = {
  'should stop monitoring tasks': {
    action: () => dispatch => stopMonitoringTasks('some-monitor-id')(dispatch, noop),
    test: () => expect(clearInterval).toHaveBeenCalledWith(monitor.intervalId),
  },
  'should start monitoring tasks': {
    action: () => (dispatch) => {
      const id = 'some-monitor-id';
      const { interval, params } = monitor;

      return startMonitoringTasks({ id, interval, params })(dispatch, noop);
    },
    test: () => expect(setInterval).toHaveBeenCalled(),
  },
  'should not start monitoring tasks if already monitored': {
    action: () => (dispatch) => {
      selectIsMonitorActive.mockImplementation(() => true);

      const id = 'some-monitor-id';
      const { interval, params } = monitor;

      return startMonitoringTasks({ id, interval, params })(dispatch, noop);
    },
    test: () => expect(setInterval).not.toHaveBeenCalled(),
  },
  'should run monitor lifecycle': {
    action: () => (dispatch) => {
      api.post.mockImplementation(async () => ({
        status: 200,
        data: [{ results: 'some-tasks' }],
      }));
      return runMonitorLifecycle('some-monitor-id')(dispatch, noop);
    },
    test: () => expect(api.post.mock.calls).toMatchSnapshot(),
  },
  'should run monitor lifecycle and fail because bad server response': () => (dispatch) => {
    api.post.mockImplementation(async () => {
      throw new Error('some error');
    });
    return runMonitorLifecycle('some-monitor-id')(dispatch, noop);
  },
  'should run monitor lifecycle and fail because unauthorized': () => (dispatch) => {
    api.post.mockImplementation(async () => ({
      status: 401,
    }));
    return runMonitorLifecycle('some-monitor-id')(dispatch, noop);
  },
};

describe('TasksMonitor actions', () => {
  beforeEach(() => {
    jest.useFakeTimers();

    selectMonitor.mockImplementation(() => monitor);
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
