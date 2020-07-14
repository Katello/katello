export const selectOrganizationState = state => state.katello.organization;

export const selectManifestName = state =>
  selectOrganizationState(state).owner_details?.upstreamConsumer?.name;

// for use in ManageManifestModal to replace getManifestName()
export const selectManifestHref = state =>
  selectManifestName(state) && [
    'https://',
    selectOrganizationState(state).owner_details.upstreamConsumer.webUrl,
    selectOrganizationState(state).owner_details.upstreamConsumer.uuid,
  ].join('/');

export const selectIsManifestImported = state =>
  !!selectOrganizationState(state).owner_details?.upstreamConsumer?.webUrl;

export const selectSimpleContentAccessEnabled = state =>
  selectOrganizationState(state).simple_content_access;
