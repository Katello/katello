import { task, taskWithErrors } from './TasksMonitor.fixtures';
import { notifyTaskStartedToast, notifyTaskFinishedToast } from '../TasksMonitorHelpers';

jest.mock('../../../move_to_foreman/foreman_toast_notifications', () => ({
  notify: jest.fn(data => data),
}));

describe('TasksMonitor helpers', () => {
  it('should notify task started toast', () =>
    expect(notifyTaskStartedToast(task)).toMatchSnapshot());

  it('should notify task finished toast', () =>
    expect(notifyTaskFinishedToast(task)).toMatchSnapshot());

  it('should notify task finished toast with errors', () =>
    expect(notifyTaskFinishedToast(taskWithErrors)).toMatchSnapshot());
});
