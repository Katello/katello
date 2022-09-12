import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import SYNC_PLANS_KEY from './SyncPlanConstants';

export const selectSyncPlans = (state, index = '') => selectAPIResponse(state, SYNC_PLANS_KEY + index) || {};

export const selectPlansStatus = (state, index = '') =>
  selectAPIStatus(state, SYNC_PLANS_KEY + index) || STATUS.PENDING;

export const selectSyncPlansError = (state, index = '') =>
  selectAPIError(state, SYNC_PLANS_KEY + index);
