import { translate as __ } from 'foremanReact/common/I18n';

export const CDN_URL = 'https://cdn.redhat.com';

export const [CDN, NETWORK_SYNC, EXPORT_SYNC, CUSTOM_CDN] = ['redhat_cdn', 'network_sync', 'export_sync', 'custom_cdn'];
export const CDN_CONFIGURATION_TYPES = {
  redhat_cdn: __('Red Hat CDN'),
  custom_cdn: __('Custom CDN'),
  network_sync: __('Network Sync'),
  export_sync: __('Export Sync'),
};

export const DEFAULT_ORGANIZATION_LABEL = 'Default_Organization';
export const DEFAULT_CONTENT_VIEW_LABEL = 'Default_Organization_View';
export const DEFAULT_LIFECYCLE_ENVIRONMENT_LABEL = 'Library';
