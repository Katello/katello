import { selectAPIError, selectAPIResponse, selectAPIStatus } from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import ACS_KEY, { acsDetailsKey, CREATE_ACS_KEY, PRODUCTS_KEY } from './ACSConstants';

export const selectAlternateContentSources = (state, index = '') => selectAPIResponse(state, ACS_KEY + index) || {};

export const selectAlternateContentSourcesStatus = (state, index = '') =>
  selectAPIStatus(state, ACS_KEY + index) || STATUS.PENDING;

export const selectAlternateContentSourcesError = (state, index = '') =>
  selectAPIError(state, ACS_KEY + index);

export const selectCreateACS = (state, name) =>
  selectAPIResponse(state, CREATE_ACS_KEY + name) || {};

export const selectCreateACSStatus = (state, name) =>
  selectAPIStatus(state, CREATE_ACS_KEY + name) || STATUS.PENDING;

export const selectCreateACSError = (state, name) =>
  selectAPIError(state, CREATE_ACS_KEY + name);

export const selectACSDetails = (state, acsId) =>
  selectAPIResponse(state, acsDetailsKey(acsId)) || {};

export const selectACSDetailsStatus =
    (state, acsId) => selectAPIStatus(state, acsDetailsKey(acsId)) || STATUS.PENDING;

export const selectACSDetailsError =
    (state, acsId) => selectAPIError(state, acsDetailsKey(acsId));

export const selectProducts = state => selectAPIResponse(state, PRODUCTS_KEY) || {};

export const selectProductsStatus = state => selectAPIStatus(state, PRODUCTS_KEY) || STATUS.PENDING;
