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

describe('Task selectors', () => {
  it('selects if polling a task', () => {
    expect(selectIsPollingTask(state, 'TEST')).toBe(true);
  });

  it('selects if not polling a task', () => {
    expect(selectIsPollingTask({})).toBe(false);
  });

  it('selects if polling tasks', () => {
    expect(selectIsPollingTasks(state, 'TEST')).toBe(true);
  });

  it('selects if not polling tasks', () => {
    expect(selectIsPollingTasks({})).toBe(false);
  });
});
