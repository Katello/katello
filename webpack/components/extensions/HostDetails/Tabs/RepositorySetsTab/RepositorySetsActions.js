import { translate as __ } from 'foremanReact/common/I18n';
import {
  API_OPERATIONS,
  get,
  put,
} from 'foremanReact/redux/API';
import { errorToast } from '../../../../../scenes/Tasks/helpers';

import katelloApi, { foremanApi } from '../../../../../services/api';
import {
  CONTENT_OVERRIDES_KEY,
  REPOSITORY_SETS_KEY,
} from './RepositorySetsConstants';

export const getHostRepositorySets = params => get({
  type: API_OPERATIONS.GET,
  key: REPOSITORY_SETS_KEY,
  url: katelloApi.getApiUrl('/repository_sets'),
  errorToast: error => errorToast(error),
  params,
});

export const setContentOverrides = ({
  hostId,
  search,
  enabled,
  remove = false,
  updateResults,
  singular,
}) => put({
  type: API_OPERATIONS.PUT,
  key: CONTENT_OVERRIDES_KEY,
  url: foremanApi.getApiUrl(`/hosts/${hostId}/subscriptions/content_override`),
  params: {
    content_overrides_search: {
      search,
      enabled,
      remove,
    },
  },
  updateData: (_, resp) => updateResults(resp),
  successToast: () => {
    if (enabled) {
      return singular ? __('Repository set enabled') :
        __('Repository sets enabled');
    } else if (remove) {
      return singular ? __('Repository set reset to default') : __('Repository sets reset to default');
    }
    return singular ? __('Repository set disabled') : __('Repository sets disabled');
  },
  errorToast: error => errorToast(error),
});
