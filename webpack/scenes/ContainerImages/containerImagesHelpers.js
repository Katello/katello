import { translate as __ } from 'foremanReact/common/I18n';
import { capitalize } from '../../utils/helpers';

export const STATUS = {
  PENDING: 'PENDING',
  RESOLVED: 'RESOLVED',
  ERROR: 'ERROR',
};

export const getManifest = (data) => {
  if (!data) return null;
  return data.manifest || data.manifest_schema2 || data.manifest_schema1;
};

export const formatManifestType = (manifest) => {
  if (!manifest || !manifest.manifest_type) return 'N/A';

  if (manifest.manifest_type === 'image') {
    if (manifest.is_bootable) {
      return __('Bootable');
    }
    if (manifest.is_flatpak) {
      return __('Flatpak');
    }
  }

  return capitalize(manifest.manifest_type);
};

export const getShortDigest = (digest) => {
  if (!digest) return 'N/A';
  const parts = digest.split(':');
  if (parts.length === 2) {
    return `${parts[0]}:${parts[1].substring(0, 12)}`;
  }
  return digest.substring(0, 19);
};

export const hasLabelsOrAnnotations = (manifest) => {
  if (!manifest) return false;
  return (Object.keys(manifest.labels || {}).length > 0) ||
         (Object.keys(manifest.annotations || {}).length > 0);
};

export const anyChildHasLabelsOrAnnotations = (manifest) => {
  if (!manifest?.manifests) return false;
  return manifest.manifests.some(child => hasLabelsOrAnnotations(child));
};
