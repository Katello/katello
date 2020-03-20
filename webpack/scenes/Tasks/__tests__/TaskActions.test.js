import { testActionSnapshotWithFixtures } from 'react-redux-test-utils';
import { getTaskSuccessResponse } from './task.fixtures';

import {
  startPollingTask,
  stopPollingTask,
  startPollingTasks,
  stopPollingTasks,
  toastTaskFinished,
} from '../TaskActions';

describe('task actions', () => testActionSnapshotWithFixtures({
  'can search tasks': () => startPollingTasks('TEST'),
  'can stop searching tasks': () => stopPollingTasks('TEST'),
  'can poll a task': () => startPollingTask('TEST', { id: '12345' }),
  'can stop polling a task': () => stopPollingTask('TEST'),
  'can toast a finished task': () => toastTaskFinished(getTaskSuccessResponse),
}));
