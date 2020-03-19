import { testSelectorsSnapshotWithFixtures } from 'react-redux-test-utils';
import {
  selectIsPollingTask,
  selectIsPollingTasks,
} from '../TaskSelectors';

const state = {
  intervals: {
    TEST_POLL_TASK: 1,
    TEST_TASK_SEARCH: 3,
  },
};

const fixtures = {
  'selects if polling a task': () => selectIsPollingTask(state, 'TEST'),
  'selects if not polling a task': () => selectIsPollingTask({}),
  'selects if polling tasks': () => selectIsPollingTasks(state, 'TEST'),
  'selects if not polling tasks': () => selectIsPollingTasks({}),
};

describe('Task selectors', () => testSelectorsSnapshotWithFixtures(fixtures));
