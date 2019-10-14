export const selectSubscriptionsState = state =>
  state.katello.subscriptions;

export const selectSearchQuery = state =>
  selectSubscriptionsState(state).searchQuery;

export const selectDeleteModalOpened = state =>
  selectSubscriptionsState(state).deleteModalOpened;

export const selectTaskModalOpened = state =>
  selectSubscriptionsState(state).taskModalOpened;

export const selectDeleteButtonDisabled = state =>
  selectSubscriptionsState(state).deleteButtonDisabled;

export const selectActivePermissions = state =>
  selectSubscriptionsState(state).activePermissions;

export const selectSubscriptionsTasks = state =>
  selectSubscriptionsState(state).tasks;

export const selectTableSettings = (state, tableName) =>
  state.katello.settings.tables[tableName] || undefined;
