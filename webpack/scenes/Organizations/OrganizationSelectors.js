export const selectOrganizationState = state => state.katello.organization;

export const selectSimpleContentAccessEnabled = state =>
  selectOrganizationState(state).simple_content_access;
