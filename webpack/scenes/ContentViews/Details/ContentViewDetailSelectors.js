import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import CONTENT_VIEWS_KEY from '../ContentViewsConstants';

export const selectCVDetails = (state, cvId) =>
  selectAPIResponse(state, `${CONTENT_VIEWS_KEY}_${cvId}`) || {};

export const selectCVDetailStatus =
  (state, cvId) => selectAPIStatus(state, `${CONTENT_VIEWS_KEY}_${cvId}`) || STATUS.PENDING;

export const selectCVDetailError =
  (state, cvId) => selectAPIError(state, `${CONTENT_VIEWS_KEY}_${cvId}`);


export const selectIsCVUpdating = state => state.katello?.contentViewDetails?.updating;
