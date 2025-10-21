import { translate as __ } from 'foremanReact/common/I18n';

const ACS_KEY = 'ACS';
export const CREATE_ACS_KEY = 'ACS_CREATE';
export const EDIT_ACS_KEY = 'ACS_EDIT';
export const DELETE_ACS_KEY = 'ACS_DELETE';
export const SMART_PROXY_KEY = 'SMART_PROXY';
export const PRODUCTS_KEY = 'PRODUCTS';
export const SSL_CERTS = 'SSL_CERTS';
export const BULK_ACS_REFRESH_KEY = 'BULK_ACS_REFRESH';
export const BULK_ACS_DELETE_KEY = 'BULK_ACS_DELETE';
export const acsRefreshKey = acsId => `${ACS_KEY}_REFRESH_${acsId}`;
export const acsDetailsKey = acsId => `${ACS_KEY}_DETAILS_${acsId}`;

export const YUM = __('Yum');
export const FILE = __('File');
export const DEB = __('Deb');

export const ACS_TYPE_TRANSLATIONS_ENUM = {
  [YUM]: 'yum',
  [FILE]: 'file',
  [DEB]: 'deb',
};

export default ACS_KEY;
