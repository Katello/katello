export const HOST_PACKAGES_KEY = 'HOST_PACKAGES';

export const PACKAGES_VERSION_STATUSES = {
  UPGRADABLE: 'Upgradable',
  UP_TO_DATE: 'Up-to date',
};

export const VERSION_STATUSES_TO_PARAM = {
  [PACKAGES_VERSION_STATUSES.UPGRADABLE]: 'upgradable',
  [PACKAGES_VERSION_STATUSES.UP_TO_DATE]: 'up-to-date',
};

export default HOST_PACKAGES_KEY;
