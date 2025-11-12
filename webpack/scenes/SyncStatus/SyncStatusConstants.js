import { translate as __ } from 'foremanReact/common/I18n';

const SYNC_STATUS_KEY = 'SYNC_STATUS';
export const SYNC_STATUS_POLL_KEY = 'SYNC_STATUS_POLL';
export const SYNC_REPOSITORIES_KEY = 'SYNC_REPOSITORIES';
export const CANCEL_SYNC_KEY = 'CANCEL_SYNC';

export const SYNC_STATE_STOPPED = 'stopped';
export const SYNC_STATE_ERROR = 'error';
export const SYNC_STATE_NEVER_SYNCED = 'never_synced';
export const SYNC_STATE_RUNNING = 'running';
export const SYNC_STATE_CANCELED = 'canceled';
export const SYNC_STATE_PAUSED = 'paused';

export const SYNC_STATE_LABELS = {
  [SYNC_STATE_STOPPED]: __('Syncing Complete'),
  [SYNC_STATE_ERROR]: __('Sync Incomplete'),
  [SYNC_STATE_NEVER_SYNCED]: __('Never Synced'),
  [SYNC_STATE_RUNNING]: __('Running'),
  [SYNC_STATE_CANCELED]: __('Canceled'),
  [SYNC_STATE_PAUSED]: __('Paused'),
};

export default SYNC_STATUS_KEY;
