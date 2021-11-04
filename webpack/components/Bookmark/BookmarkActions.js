import { API_OPERATIONS, get, post } from 'foremanReact/redux/API';
import { translate as __ } from 'foremanReact/common/I18n';
import { getBookmarkErrorMsgs } from '../../utils/helpers';
import { bookmarkKey, CREATE_BOOKMARK } from './BookmarkConstants';


export const getBookmarks = key =>
  get({
    type: API_OPERATIONS.GET,
    key: bookmarkKey(key),
    url: '/api/v2/bookmarks',
    params: { search: `controller=${key}` },
  });

export const createBookmark = (params, handleSuccess) =>
  post({
    type: API_OPERATIONS.POST,
    key: CREATE_BOOKMARK,
    url: '/api/v2/bookmarks',
    params,
    handleSuccess,
    errorToast: error =>
      __(`Something went wrong while adding a bookmark: ${getBookmarkErrorMsgs(error.response)}`),
  });
