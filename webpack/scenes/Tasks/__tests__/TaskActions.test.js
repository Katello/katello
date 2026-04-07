import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';
import { getTaskSuccessResponse } from './task.fixtures';

import {
  startPollingTask,
  stopPollingTask,
  startPollingTasks,
  stopPollingTasks,
  toastTaskFinished,
} from '../TaskActions';

const mockStore = configureMockStore([thunk]);

describe('task actions', () => {
  it('can search tasks', () => {
    const action = startPollingTasks('TEST');
    expect(action.type).toBe('API_GET');
    expect(action.payload.key).toBe('TEST_TASK_SEARCH');
    expect(action.payload.url).toContain('/foreman_tasks/api/tasks');
    expect(action.payload.params).toEqual({ search: '' });
    expect(action.interval).toBe(5000);
  });

  it('can stop searching tasks', () => {
    const action = stopPollingTasks('TEST');
    expect(action.type).toBe('STOP_INTERVAL');
    expect(action.key).toBe('TEST_TASK_SEARCH');
  });

  it('can poll a task', () => {
    const action = startPollingTask('TEST', { id: '12345' });
    expect(action.type).toBe('API_GET');
    expect(action.payload.key).toBe('TEST_POLL_TASK');
    expect(action.payload.url).toContain('/foreman_tasks/api/tasks/12345');
    expect(action.interval).toBe(5000);
  });

  it('can stop polling a task', () => {
    const action = stopPollingTask('TEST');
    expect(action.type).toBe('STOP_INTERVAL');
    expect(action.key).toBe('TEST_POLL_TASK');
  });

  it('can toast a finished task', async () => {
    const store = mockStore({});
    await store.dispatch(toastTaskFinished(getTaskSuccessResponse));
    const actions = store.getActions();
    expect(actions).toHaveLength(1);
    expect(actions[0].type).toBe('toasts/addToast');
    expect(actions[0].payload.toast.message).toContain('Refresh Manifest');
    expect(actions[0].payload.toast.message).toContain('pending');
    expect(actions[0].payload.toast.link.children).toBe('Go to task page');
    expect(actions[0].payload.toast.link.href).toContain('eb1b6271-8a69-4d98-84fc-bea06ddcc166');
  });
});
