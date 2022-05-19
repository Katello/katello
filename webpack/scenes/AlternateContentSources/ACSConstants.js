import { translate as __ } from 'foremanReact/common/I18n';

const ACS_KEY = 'ACS';
export const CREATE_ACS_KEY = 'ACS_CREATE';
export const DELETE_ACS_KEY = 'ACS_DELETE';
export const SMART_PROXY_KEY = 'SMART_PROXY';
export const SSL_CERTS = 'SSL_CERTS';
export const acsRefreshKey = acsId => `${ACS_KEY}_REFRESH_${acsId}`;

export const YUM = __('Yum');
export const FILE = __('File');

export const ACS_TYPE_TRANSLATIONS_ENUM = {
  [YUM]: 'yum',
  [FILE]: 'file',
};

export default ACS_KEY;
