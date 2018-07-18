import { testSelectorsSnapshotWithFixtures } from '../../../move_to_pf/test-utils/testHelpers';
import { tasksMonitorState, monitorId, monitorIdWithTasks } from './TasksMonitor.fixtures';

import { selectTasksMonitorState, selectMonitor, selectMonitorTasks, selectIsMonitorActive } from '../TasksMonitorSelectors';

const emptyStateFixture = {
  katello: {
    tasksMonitor: 'some-data',
  },
};

const stateFixture = {
  katello: {
    tasksMonitor: tasksMonitorState,
  },
};

const fixtures = {
  'should select the tasks monitor state': () => selectTasksMonitorState(emptyStateFixture),
  'should select monitor': () => selectMonitor(stateFixture, monitorId),
  'should select monitor tasks': () => selectMonitorTasks(stateFixture, monitorIdWithTasks),
  'should select is monitor active': () => selectIsMonitorActive(stateFixture, monitorIdWithTasks),
};

describe('TasksMonitor selectors', () => testSelectorsSnapshotWithFixtures(fixtures));
