export const task = {
  id: 'some-id',
  result: 'some-results',
  humanized: {
    action: 'some-action',
  },
  progress: 0.09,
};

export const taskWithErrors = {
  ...task,
  id: 'some-id-with-errors',
  errors: true,
  humanized: {
    ...task.humanized,
    errors: ['some error number 1', 'some error number 2'],
  },
};

export const monitorId = 'some-monitor-id';
export const monitorIdWithTasks = 'some-monitor-id-with-tasks';

export const monitor = {
  interval: 5000,
  intervalId: 1234,
  params: { param1: 'some-param-1', param2: 'some-param-2' },
  tasks: [],
};

export const monitorWithTasks = {
  ...monitor,
  tasks: [task, taskWithErrors],
};

export const tasksMonitorState = {
  [monitorId]: monitor,
  [monitorIdWithTasks]: monitorWithTasks,
};
