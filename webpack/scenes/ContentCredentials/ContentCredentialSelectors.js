import {
  selectAPIStatus,
  selectAPIResponse,
  selectAPIError,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';

import { GET_CONTENT_CREDENTIALS_KEY } from './ContentCredentialConstants';

export const selectContentCredentials = (state) => {
  const response = selectAPIResponse(state, GET_CONTENT_CREDENTIALS_KEY);
  return response.results;
};

export const selectContentCredentialsStatus = state =>
  selectAPIStatus(state, GET_CONTENT_CREDENTIALS_KEY) || STATUS.PENDING;

export const selectContentCredentialsErrorMessage = (state) => {
  const error = selectAPIError(state, GET_CONTENT_CREDENTIALS_KEY);
  if (!error) {
    return null;
  }

  // Check for structured error response with missing permissions
  if (error.response?.data?.error) {
    const errorData = error.response.data.error;
    if (errorData.missing_permissions?.length > 0) {
      return errorData;
    }
  }
  return null;
};
