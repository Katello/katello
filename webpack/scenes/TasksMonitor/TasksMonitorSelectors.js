export const selectTasksMonitorState = state => state.katello.tasksMonitor;

export const selectMonitor = (state, monitorId) =>
  selectTasksMonitorState(state)[monitorId];

export const selectMonitorTasks = (state, monitorId) => {
  const monitor = selectMonitor(state, monitorId);

  return monitor && monitor.tasks;
};

export const selectIsMonitorActive = (state, monitorId) => {
  const monitor = selectMonitor(state, monitorId);

  return monitor && !!monitor.intervalId;
};
