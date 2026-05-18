import {
  selectAPIStatus,
  selectAPIResponse,
  selectAPIError,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';

import {
  GET_CONTENT_CREDENTIALS_KEY,
  CREATE_CONTENT_CREDENTIAL_KEY,
} from './ContentCredentialConstants';

export const selectContentCredentials = (state) => {
  const response = selectAPIResponse(state, GET_CONTENT_CREDENTIALS_KEY);
  return response.results;
};

export const selectContentCredentialsStatus = state =>
  selectAPIStatus(state, GET_CONTENT_CREDENTIALS_KEY) || STATUS.PENDING;

export const selectCreateContentCredential = state =>
  selectAPIResponse(state, CREATE_CONTENT_CREDENTIAL_KEY) || {};

export const selectCreateContentCredentialStatus = state =>
  selectAPIStatus(state, CREATE_CONTENT_CREDENTIAL_KEY) || STATUS.PENDING;

export const selectCreateContentCredentialError = state =>
  selectAPIError(state, CREATE_CONTENT_CREDENTIAL_KEY);
