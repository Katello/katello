// Activation Keys helpers

export const validateAKField = (hostGroupId, userKeys, hgKeys) => {
  if (hostGroupId === '') {
    return (userKeys?.length > 0 ? 'success' : 'error');
  }

  if (userKeys === undefined && hgKeys === undefined) {
    return ('default');
  }

  return ((userKeys?.length > 0 || hgKeys?.length > 0) ? 'success' : 'error');
};

export const akHasValidValue = (hostGroupId, userKeys, hgKeys) => {
  if (hostGroupId === '') {
    return (userKeys?.length > 0);
  }

  return (hgKeys?.length > 0 || userKeys?.length > 0);
};
