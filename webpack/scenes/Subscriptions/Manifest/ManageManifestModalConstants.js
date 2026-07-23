export const MANIFEST_TAB = 1;
export const HISTORY_TAB = 2;
export const CDN_TAB = 3;

export const getDefaultTabKey = showManifestTab => (showManifestTab ? MANIFEST_TAB : HISTORY_TAB);
