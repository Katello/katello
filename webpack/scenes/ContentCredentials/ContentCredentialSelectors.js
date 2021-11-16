import {
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';

import { GET_CONTENT_CREDENTIALS_KEY } from './ContentCredentialConstants';

export const selectContentCredentials = (state) => {
  const response = selectAPIResponse(state, GET_CONTENT_CREDENTIALS_KEY);
  return response.results;
};

export default selectContentCredentials;
