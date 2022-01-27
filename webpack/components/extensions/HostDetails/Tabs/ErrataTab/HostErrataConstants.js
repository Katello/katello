export const HOST_ERRATA_KEY = 'HOST_ERRATUM';
export const HOST_ERRATA_APPLICABILITY_KEY = 'HOST_ERRATA_APPLICABILITY';
export const HOST_ERRATA_APPLY_KEY = 'HOST_ERRATUM_APPLY';

export const ERRATA_TYPES = {
  SECURITY: 'Security',
  BUGFIX: 'Bugfix',
  ENHANCEMENT: 'Enhancement',
};
export const ERRATA_SEVERITIES = {
  NOT_APPLICABLE: 'N/A',
  LOW: 'Low',
  MODERATE: 'Moderate',
  IMPORTANT: 'Important',
  CRITICAL: 'Critical',
};

export const TYPES_TO_PARAM = {
  [ERRATA_TYPES.SECURITY]: 'security',
  [ERRATA_TYPES.BUGFIX]: 'bugfix',
  [ERRATA_TYPES.ENHANCEMENT]: 'enhancement',
};

export const SEVERITIES_TO_PARAM = {
  [ERRATA_SEVERITIES.NOT_APPLICABLE]: 'None',
  [ERRATA_SEVERITIES.LOW]: 'Low',
  [ERRATA_SEVERITIES.MODERATE]: 'Moderate',
  [ERRATA_SEVERITIES.IMPORTANT]: 'Important',
  [ERRATA_SEVERITIES.CRITICAL]: 'Critical',
};

export const PARAM_TO_FRIENDLY_NAME = {
  security: 'Security',
  bugfix: 'Bugfix',
  enhancement: 'Enhancement',
  none: 'N/A',
  low: 'Low',
  moderate: 'Moderate',
  important: 'Important',
  critical: 'Critical',
};

export default HOST_ERRATA_KEY;

export const ERRATA_SEARCH_QUERY = 'Errata search query';
