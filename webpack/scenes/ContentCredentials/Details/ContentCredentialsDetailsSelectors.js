import { selectAPIStatus, selectAPIError, selectAPIResponse } from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import {
  contentCredentialDetailsKey,
} from './ContentCredentialsDetailsActions';

export const selectContentCredentialDetails = (state, credentialId) =>
  selectAPIResponse(state, contentCredentialDetailsKey(credentialId)) || {};

export const selectContentCredentialDetailsStatus = (state, credentialId) =>
  selectAPIStatus(state, contentCredentialDetailsKey(credentialId)) || STATUS.PENDING;

export const selectContentCredentialDetailsError = (state, credentialId) =>
  selectAPIError(state, contentCredentialDetailsKey(credentialId));

export const selectIsContentCredentialUpdating = (state, credentialId) =>
  selectAPIStatus(state, contentCredentialDetailsKey(credentialId)) === STATUS.PENDING;
