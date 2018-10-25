export const selectSubscriptionsState = state =>
  state.katello.subscriptions;

export const selectManifestModalOpened = state =>
  selectSubscriptionsState(state).manifestModalOpened;

export const selectSubscriptionsTasks = state =>
  selectSubscriptionsState(state).tasks;
