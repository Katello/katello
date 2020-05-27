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

export const selectIsTaskPending = state =>
  selectSubscriptionsTask(state).pending || selectSubscriptionsTask(state).result === 'pending';

export const selectTableSettings = (state, tableName) =>
  state.katello.settings.tables[tableName] || undefined;
