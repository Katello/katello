const path = require('path');

const foremanFull =
  process.env.FOREMAN_PATH || path.resolve(__dirname, '../foreman');

// @testing-library/dom@9 calls prettyFormat.format. Jest 26's root pretty-format
// is a default-export function. Katello lists Foreman's node_modules first, so
// that root copy wins unless DOM's own nested pretty-format is selected.
const testingLibraryPrettyFormat = path.join(
  foremanFull,
  'node_modules/@testing-library/dom/node_modules/pretty-format'
);

const testingLibraryDomDir = `${path.sep}@testing-library${path.sep}dom${path.sep}`;

// === BEGIN React 16/18 dual-compat (remove after Foreman is React 18-only) ===
// On React 18-only: const nestedPrettyFormat = require.resolve(testingLibraryPrettyFormat);
// and drop the `nestedPrettyFormat &&` guard in the resolver below.
let nestedPrettyFormat = null;
try {
  // Absent on @testing-library/dom versions that use the root pretty-format (React 16).
  nestedPrettyFormat = require.resolve(testingLibraryPrettyFormat);
} catch (err) {
  nestedPrettyFormat = null;
}
// === END React 16/18 dual-compat ===

module.exports = (request, options) => {
  if (
    nestedPrettyFormat &&
    request === 'pretty-format' &&
    options.basedir &&
    options.basedir.includes(testingLibraryDomDir)
  ) {
    return nestedPrettyFormat;
  }

  return options.defaultResolver(request, options);
};
