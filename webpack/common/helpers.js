const handleMissingOrg = (orgId, dispatch, type) => {
  if (!orgId) {
    const errorMessage = 'No organization specified';
    dispatch({
      type,
      payload: {
        errors: [errorMessage],
        displayMessage: errorMessage,
      },
    });
    return true;
  }
  return false;
};

export default handleMissingOrg;
