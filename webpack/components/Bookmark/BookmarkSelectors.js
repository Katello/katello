import {
  selectAPIStatus,
  selectAPIError,
  selectAPIResponse,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import { bookmarkKey } from './BookmarkConstants';

export const selectBookmarks = (state, key) => selectAPIResponse(state, bookmarkKey(key)) || {};

export const selectBookmarkStatus = (state, key) =>
  selectAPIStatus(state, bookmarkKey(key)) || STATUS.PENDING;

export const selectBookmarkError = (state, key) =>
  selectAPIError(state, bookmarkKey(key));
