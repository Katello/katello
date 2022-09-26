export const isValidUrl = (urlString) => {
  try {
    const urlFromString = new URL(urlString);
    return (urlFromString.protocol === 'https:' || urlFromString.protocol === 'http:' || urlFromString.protocol === 'file:');
  } catch (e) {
    return false;
  }
};

export const areSubPathsValid = (subpathsString) => {
  try {
    if (subpathsString === '') {
      return true;
    }
    return subpathsString.split(',').every((subpath) => {
      const trimmedPath = subpath.trim();
      return (!trimmedPath.startsWith('/') && trimmedPath.endsWith('/'));
    });
  } catch (e) {
    return false;
  }
};
