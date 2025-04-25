export const pendingOverrideToApiParamItem = ({ repoLabel, value }) => {
  switch (Number(value)) {
  case 0: // No change
    return null;
  case 1: // Override to enabled
    return {
      content_label: repoLabel,
      name: 'enabled',
      value: true,
    };
  case 2: // Override to disabled
    return {
      content_label: repoLabel,
      name: 'enabled',
      value: false,
    };
  case 3: // Reset to default
    return {
      content_label: repoLabel,
      name: 'enabled',
      remove: true,
    };
  default:
    return null;
  }
};

export default pendingOverrideToApiParamItem;
