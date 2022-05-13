import {
  selectAPIStatus,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';

import { GET_CONTENT_CREDENTIALS_KEY } from './ContentCredentialConstants';

export const selectContentCredentials = (state) => {
  const response = selectAPIResponse(state, GET_CONTENT_CREDENTIALS_KEY);
  return response.results;
};

export const selectContentCredentialsStatus = state =>
  selectAPIStatus(state, GET_CONTENT_CREDENTIALS_KEY) || STATUS.PENDING;
