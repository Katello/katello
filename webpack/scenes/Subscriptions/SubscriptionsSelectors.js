export const selectSubscriptionsState = state =>
  state.katello.subscriptions;

export const selectSearchQuery = state =>
  selectSubscriptionsState(state).searchQuery;

export const selectDeleteModalOpened = state =>
  selectSubscriptionsState(state).deleteModalOpened;

export const selectDeleteButtonDisabled = state =>
  selectSubscriptionsState(state).deleteButtonDisabled;

export const selectActivePermissions = state =>
  selectSubscriptionsState(state).activePermissions;

export const selectSubscriptionsTask = state =>
  selectSubscriptionsState(state).task;

export const selectIsTaskPending = (state) => {
  const task = selectSubscriptionsTask(state);
  if (task) {
    return task.pending || task.result === 'pending';
  }
  return false;
};

export const selectManifestActionStarted = state =>
  selectSubscriptionsState(state).manifestActionStarted;

export const selectHasUpstreamConnection = state =>
  selectSubscriptionsState(state).hasUpstreamConnection;
