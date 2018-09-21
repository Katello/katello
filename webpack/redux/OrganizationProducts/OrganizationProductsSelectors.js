import { ORGANIZATION_PRODUCTS_KEY } from './OrganizationProductsConstants';

export const selectOrganizationProductsState = state =>
  state.katello[ORGANIZATION_PRODUCTS_KEY];

export const selectOrganizationProducts = state =>
  selectOrganizationProductsState(state).results;
