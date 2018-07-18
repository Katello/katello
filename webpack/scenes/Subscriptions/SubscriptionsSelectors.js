import { selectOrganization } from '../Organizations/OrganizationSelectors';
import { selectMonitorTasks } from '../TasksMonitor/TasksMonitorSelectors';
import { SUBSCRIPTIONS_MONITOR_TASKS_ID } from './SubscriptionConstants';

import { manifestExists as doesManifestExist } from './SubscriptionHelpers';

export const selectSubscriptionsState = state => state.katello.subscriptions;

export const selectMonitorTasksInProgress = (
  state,
  monitorId = SUBSCRIPTIONS_MONITOR_TASKS_ID,
) => {
  const tasks = selectMonitorTasks(state, monitorId) || [];

  return tasks.filter(task => task.pending);
};

export const selectMonitorCurrentTask = (
  state,
  monitorId = SUBSCRIPTIONS_MONITOR_TASKS_ID,
) => {
  const tasks = selectMonitorTasks(state, monitorId) || [];

  return tasks[0];
};

export const selectHasMonitorTasksInProgress = (
  state,
  monitorId = SUBSCRIPTIONS_MONITOR_TASKS_ID,
) => selectMonitorTasksInProgress(state, monitorId).length > 0;

export const selectManifestExists = (state) => {
  const organization = selectOrganization(state);

  return doesManifestExist(organization);
};

export const selectManifestActionsDisabled = (state) => {
  const { disconnected } = selectSubscriptionsState(state);
  const hasMonitorTasksInProgress = selectHasMonitorTasksInProgress(state);
  const manifestExists = selectManifestExists(state);

  return hasMonitorTasksInProgress || disconnected || !manifestExists;
};

export const selectManifestActionsDisabledReason = (state) => {
  const { disconnected } = selectSubscriptionsState(state);
  const hasMonitorTasksInProgress = selectHasMonitorTasksInProgress(state);
  const manifestExists = selectManifestExists(state);

  if (disconnected) return __('This is disabled because disconnected mode is enabled.');
  if (hasMonitorTasksInProgress) return __('This is disabled because a manifest related task is in progress.');
  if (!manifestExists) return __('This is disabled because no manifest has been uploaded.');

  return '';
};

export const selectDeleteButtonDisabledReason = (state) => {
  const { disconnected } = selectSubscriptionsState(state);
  const hasMonitorTasksInProgress = selectHasMonitorTasksInProgress(state);

  if (disconnected) return __('This is disabled because disconnected mode is enabled.');
  if (hasMonitorTasksInProgress) return __('This is disabled because a manifest related task is in progress.');

  return __('This is disabled because no subscriptions are selected.');
};
