import { testReducerSnapshotWithFixtures } from '../../../move_to_pf/test-utils/testHelpers';
import { monitor, monitorId } from './TasksMonitor.fixtures';

import {
  TASKS_MONITOR_STARTED,
  TASKS_MONITOR_STOPPED,
  TASKS_MONITOR_SUCCESS,
  TASKS_MONITOR_FAILED,
} from '../TasksMonitorConstants';
import reducer from '../TasksMonitorReducer';

const fixtures = {
  'should return the initial state': {},
  'should handle TASKS_MONITOR_STARTED': {
    action: {
      type: TASKS_MONITOR_STARTED,
      payload: {
        id: monitorId,
        ...monitor,
      },
    },
  },
  'should handle TASKS_MONITOR_STOPPED': {
    action: {
      type: TASKS_MONITOR_STOPPED,
      payload: {
        id: monitorId,
      },
    },
  },
  'should handle TASKS_MONITOR_SUCCESS': {
    action: {
      type: TASKS_MONITOR_SUCCESS,
      payload: {
        id: monitorId,
        tasks: 'some-tasks',
      },
    },
  },
  'should handle TASKS_MONITOR_FAILED': {
    action: {
      type: TASKS_MONITOR_FAILED,
      payload: {
        id: monitorId,
        error: new Error('some-error'),
      },
    },
  },
};

describe('TasksMonitor reducer', () => testReducerSnapshotWithFixtures(reducer, fixtures));
