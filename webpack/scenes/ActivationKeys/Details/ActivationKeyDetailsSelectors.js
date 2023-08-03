import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import { ACTIVATION_KEY } from './ActivationKeyConstants';

export const selectAKDetails = state =>
  selectAPIResponse(state, ACTIVATION_KEY) ?? {};

export const selectAKDetailsStatus = state =>
  selectAPIStatus(state, ACTIVATION_KEY) ?? STATUS.PENDING;

export const selectAKDetailsError = state =>
  selectAPIError(state, ACTIVATION_KEY);
