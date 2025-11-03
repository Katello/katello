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

  // Helper to convert option string to {label, value} object
  const optionToObject = option => ({
    label: option || __('(unset)'),
    value: option || '',
  });

  // Build unique set of all options
  const uniqOptions = new Set([
    ...(includeNoChange ? [] : ['']), // Include empty string for single edit
    ...(defaultOptions ?? []),
    ...(additionalOptions ?? []),
    ...(currentSelected ? [currentSelected] : []),
    ...(initialOption ? [initialOption] : []),
  ]);

  // Remove null/undefined
  uniqOptions.delete(null);
  uniqOptions.delete(undefined);

  // Convert to option objects
  const options = [...uniqOptions].map(optionToObject);

  // For bulk operations, prepend "No change" and ensure "(unset)" is included
  if (includeNoChange) {
    return [
      { label: __('No change'), value: noChangeValue },
      optionToObject(''), // "(unset)" option
      ...options.filter(opt => opt.value !== ''), // All other options except empty
    ];
  }

  // For single edit, return as-is
  return options;
};
