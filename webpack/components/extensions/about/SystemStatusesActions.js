import { ajaxRequestAction } from 'foremanReact/redux/actions/common';
import {
  SYSTEM_STATUSES_FAILURE,
  SYSTEM_STATUSES_SUCCESS,
  SYSTEM_STATUSES_REQUEST,
} from './SystemStatusesConsts';

// eslint-disable-next-line import/prefer-default-export
export const getSystemStatuses = url => dispatch =>
  ajaxRequestAction({
    dispatch,
    requestAction: SYSTEM_STATUSES_REQUEST,
    successAction: SYSTEM_STATUSES_SUCCESS,
    failedAction: SYSTEM_STATUSES_FAILURE,
    url,
  });
