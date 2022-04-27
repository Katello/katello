import { translate as __ } from 'foremanReact/common/I18n';

export const REPOSITORY_SETS_KEY = 'HOST_DETAIL_REPOSITORY_SETS';
export const CONTENT_OVERRIDES_KEY = 'HOST_DETAIL_CONTENT_OVERRIDES';

export const STATUSES = {
  ENABLED: __('Enabled'),
  DISABLED: __('Disabled'),
  OVERRIDDEN: __('Overridden'),
};

export const STATUS_TO_PARAM = {
  [STATUSES.ENABLED]: 'enabled',
  [STATUSES.DISABLED]: 'disabled',
  [STATUSES.OVERRIDDEN]: 'overridden',
};

export const PARAM_TO_FRIENDLY_NAME = {
  enabled: __('Enabled'),
  disabled: __('Disabled'),
  overridden: __('Overridden'),
};
