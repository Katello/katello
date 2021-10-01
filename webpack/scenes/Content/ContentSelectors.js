import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import { CONTENT_KEY, CONTENT_TYPES_KEY, CONTENT_ID_KEY, REPOSITORY_CONTENT_ID_KEY } from './ContentConstants';

export const selectContent = state =>
  selectAPIResponse(state, CONTENT_KEY) || {};

export const selectContentStatus = state =>
  selectAPIStatus(state, CONTENT_KEY) || STATUS.PENDING;

export const selectContentError = state =>
  selectAPIError(state, CONTENT_KEY);

export const selectContentTypes = state =>
  selectAPIResponse(state, CONTENT_TYPES_KEY) || {};

export const selectContentTypesStatus = state =>
  selectAPIStatus(state, CONTENT_TYPES_KEY) || STATUS.PENDING;

export const selectContentTypesError = state =>
  selectAPIError(state, CONTENT_TYPES_KEY);

export const selectContentDetails = state =>
  selectAPIResponse(state, CONTENT_ID_KEY);

export const selectContentDetailsStatus = state =>
  selectAPIStatus(state, CONTENT_ID_KEY) || STATUS.PENDING;

export const selectContentDetailsError = state =>
  selectAPIError(state, CONTENT_ID_KEY);

export const selectRepositoryContentDetails = state =>
  selectAPIResponse(state, REPOSITORY_CONTENT_ID_KEY);

export const selectRepositoryContentDetailsStatus = state =>
  selectAPIStatus(state, REPOSITORY_CONTENT_ID_KEY) || STATUS.PENDING;

export const selectRepositoryContentDetailsError = state =>
  selectAPIError(state, REPOSITORY_CONTENT_ID_KEY);
