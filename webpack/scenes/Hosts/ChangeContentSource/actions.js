
import { foremanUrl } from 'foremanReact/common/helpers';
import { get, post, put } from 'foremanReact/redux/API';
import { translate as __ } from 'foremanReact/common/I18n';

import {
  CHANGE_CONTENT_SOURCE_DATA,
  CHANGE_CONTENT_SOURCE_PROXY,
  CHANGE_CONTENT_SOURCE,
  CHANGE_CONTENT_SOURCE_VIEWS,
} from './constants';

export const getFormData = (hostIds, search) => (post({
  key: CHANGE_CONTENT_SOURCE_DATA,
  url: foremanUrl('/change_host_content_source/data'),
  params: { host_ids: hostIds, search },
  errorToast: () => __('Something went wrong while getting the data. See the logs for more information'),
}));

export const changeContentSource =
  (environmentId, contentViewId, contentSourceId, hostIds, handleSuccess, successToast) =>
    put({
      key: CHANGE_CONTENT_SOURCE,
      url: foremanUrl('/api/v2/hosts/bulk/change_content_source'),
      params: {
        environment_id: environmentId,
        content_view_id: contentViewId,
        content_source_id: contentSourceId,
        host_ids: hostIds,
      },
      errorToast: () => __('Something went wrong while updating the content source. See the logs for more information'),
      successToast,
      handleSuccess,
    });

export const getProxy = id =>
  get({
    key: CHANGE_CONTENT_SOURCE_PROXY,
    url: foremanUrl(`/katello/api/capsules/${id}`),
    errorToast: () => __('Something went wrong while loading the Smart Proxy. See the logs for more information'),
  });

export const getContentViews = environmentId =>
  get({
    key: CHANGE_CONTENT_SOURCE_VIEWS,
    url: foremanUrl('/katello/api/v2/content_views'),
    params: {
      environment_id: environmentId,
      full_result: true,
      order: 'default DESC', // shows the default CV before all other options
    },
    errorToast: () => __('Something went wrong while loading the content views. See the logs for more information'),
  });
