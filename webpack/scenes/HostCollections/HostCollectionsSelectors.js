import { HOST_COLLECTIONS_KEY } from './HostCollectionsConstants';

export const selectHostCollections = state =>
  state[HOST_COLLECTIONS_KEY] || {};

export default selectHostCollections;
