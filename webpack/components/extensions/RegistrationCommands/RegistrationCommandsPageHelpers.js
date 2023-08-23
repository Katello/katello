// Activation Keys helpers

export const validateAKField = (
  hasInteraction,
  hostGroupId,
  activationKeys,
  userKeys,
  hgKeys,
) => {
  if (hostGroupId === '') {
    return userKeys?.length > 0 ? 'success' : 'error';
  }

  if (!hasInteraction && activationKeys?.length > 0) {
    return 'default';
  }

  return userKeys?.length > 0 || hgKeys?.length > 0 ? 'success' : 'error';
};

export const akHasValidValue = (hostGroupId, userKeys, hgKeys) => {
  if (hostGroupId === '') {
    return userKeys?.length > 0;
  }

  return hgKeys?.length > 0 || userKeys?.length > 0;
};
