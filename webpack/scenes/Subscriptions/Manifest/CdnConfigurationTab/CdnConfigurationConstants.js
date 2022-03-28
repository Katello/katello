import { translate as __ } from 'foremanReact/common/I18n';

export const CDN_URL = 'https://cdn.redhat.com';

export const [CDN, UPSTREAM_SERVER, AIRGAPPED] = ['redhat_cdn', 'upstream_server', 'airgapped'];
export const CDN_CONFIGURATION_TYPES = {
  redhat_cdn: __('Red Hat CDN'),
  upstream_server: __('Upstream Foreman server'),
  airgapped: __('Air-gapped'),
};

export const DEFAULT_ORGANIZATION_LABEL = 'Default_Organization';
export const DEFAULT_CONTENT_VIEW_LABEL = 'Default_Organization_View';
export const DEFAULT_LIFECYCLE_ENVIRONMENT_LABEL = 'Library';
