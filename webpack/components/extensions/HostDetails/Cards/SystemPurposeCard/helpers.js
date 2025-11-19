import { translate as __ } from 'foremanReact/common/I18n';

/**
 * Builds dropdown options for system purpose fields
 * @param {Array} defaultOptions - Default hardcoded options (e.g., defaultRoles)
 * @param {Array} additionalOptions - Additional options from API (e.g., org-specific roles)
 * @param {Object} config - Configuration object
 * @param {*} config.currentSelected - Currently selected value (for single edit)
 * @param {*} config.initialOption - Initial value (for single edit)
 * @param {boolean} config.includeNoChange - Whether to include "No change" option (for bulk)
 * @param {string} config.noChangeValue - Value for "No change" option (default: '__no_change__')
 * @returns {Array} Array of option objects with {label, value}
 */
// eslint-disable-next-line import/prefer-default-export
export const buildSystemPurposeOptions = (
  defaultOptions,
  additionalOptions,
  config = {},
) => {
  const {
    currentSelected = null,
    initialOption = null,
    includeNoChange = false,
    noChangeValue = '__no_change__',
  } = config;

  // Collect all unique non-empty options
  const allOptions = new Set([
    ...(defaultOptions ?? []),
    ...(additionalOptions ?? []),
    ...(currentSelected ? [currentSelected] : []),
    ...(initialOption ? [initialOption] : []),
  ]);

  // Remove falsy values (null, undefined, empty string)
  allOptions.delete(null);
  allOptions.delete(undefined);
  allOptions.delete('');

  // Convert strings to option objects
  const options = [...allOptions].map(option => ({
    label: option,
    value: option,
  }));

  // Build final option list
  const unsetOption = { label: __('(unset)'), value: '' };

  if (includeNoChange) {
    // Bulk mode: "No change", "(unset)", then all options
    return [
      { label: __('No change'), value: noChangeValue },
      unsetOption,
      ...options,
    ];
  }

  // Single edit mode: "(unset)", then all options
  return [unsetOption, ...options];
};
