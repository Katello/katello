/**
 * Constructs a content view environment label from an assignment
 *
 * This function handles the backend's content view environment labeling logic:
 * - Default CV in Library: "Library"
 * - Custom CV in Library: "Library/my_cv"
 * - Any CV in other lifecycle environments: "Production/my_cv"
 *
 * @param {Object} assignment - Assignment object with lifecycle environment
 *                              and content view
 * @param {Object} assignment.cveLabel - Pre-computed label from API
 *                                       (if available)
 * @param {Array|Object} assignment.selectedEnv - Selected lifecycle
 *                                                environment (array or object)
 * @param {Object} assignment.environment - Lifecycle environment object
 *                                         (alternative to selectedEnv)
 * @param {Object} assignment.contentView - Content view object
 * @returns {string|null} The constructed label or null if invalid
 */
const buildContentViewEnvironmentLabel = (assignment) => {
  // If assignment has pre-computed label from API, use it
  if (assignment.cveLabel) return assignment.cveLabel;

  // Get lifecycle environment - support both selectedEnv array and direct environment property
  const env = assignment.selectedEnv?.[0] || assignment.environment;
  const cv = assignment.contentView;

  if (!env || !cv) return null;

  // Get labels - support both camelCase and snake_case
  const envLabel = env.label || env.lifecycle_environment_label;
  const cvLabel = cv.label || cv.content_view_label;

  if (!envLabel || !cvLabel) return null;

  // Check if this is Library lifecycle environment and Default CV
  const isLibraryEnv = env.lifecycle_environment_library || env.library;
  const isDefaultCV = cv.content_view_default || cv.default;

  // Special case: Library + Default CV = just lifecycle environment label
  return isDefaultCV && isLibraryEnv ? envLabel : `${envLabel}/${cvLabel}`;
};

export default buildContentViewEnvironmentLabel;
export { buildContentViewEnvironmentLabel };
