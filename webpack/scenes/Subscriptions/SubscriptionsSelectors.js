export const selectSubscriptionsState = state =>
  state.katello.subscriptions;

export const selectManifestModalOpened = state =>
  selectSubscriptionsState(state).manifestModalOpened;

export const selectDeleteModalOpened = state =>
  selectSubscriptionsState(state).deleteModalOpened;

export const selectSearchQuery = state =>
  selectSubscriptionsState(state).searchQuery;

export const selectTaskModalOpened = state =>
  selectSubscriptionsState(state).taskModalOpened;

export const selectDeleteButtonDisabled = state =>
  selectSubscriptionsState(state).deleteButtonDisabled;

export const selectSubscriptionsTasks = state =>
  selectSubscriptionsState(state).tasks;

export const selectTableSettings = (state, tableName) =>
  state.katello.settings.tables[tableName] || undefined;
