export const isValidUrl = (urlString, acsType = '') => {
  try {
    const urlFromString = new URL(urlString);
    let valid = urlFromString.protocol === 'https:' || urlFromString.protocol === 'http:' || urlFromString.protocol === 'file:';
    if (acsType === 'rhui') {
      valid = urlFromString.pathname.endsWith('/pulp/content');
    }
    return valid;
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

export const toList = s => (s || '').trim().split(/[,\s]+/).filter(Boolean);

const spaceSep = (s, emptyValue) => {
  const arr = toList(s);
  return arr.length ? arr.join(' ') : emptyValue;
};

export const spaceSepOrUndef = s => spaceSep(s, undefined);
export const spaceSepOrEmpty = s => spaceSep(s, '');
