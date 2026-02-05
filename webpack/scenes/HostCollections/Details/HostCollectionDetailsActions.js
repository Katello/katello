import { translate as __ } from 'foremanReact/common/I18n';
import { get, put, API_OPERATIONS } from 'foremanReact/redux/API';
import katelloApi from '../../../services/api/index';

export const getHostCollection = id => get({
  type: API_OPERATIONS.GET,
  key: `HOST_COLLECTION_DETAILS_${id}`,
  url: katelloApi.getApiUrl(`/host_collections/${id}`),
});

export const updateHostCollection = (id, params, handleSuccess) => put({
  type: API_OPERATIONS.PUT,
  key: `UPDATE_HOST_COLLECTION_${id}`,
  url: katelloApi.getApiUrl(`/host_collections/${id}`),
  params,
  successToast: () => __('Host collection updated successfully'),
  errorToast: error => error.response?.data?.error?.message || __('Failed to update host collection'),
  handleSuccess,
});

export const addHostsToCollection = (id, hostIds, handleSuccess, handleError) => put({
  type: API_OPERATIONS.PUT,
  key: `ADD_HOSTS_TO_COLLECTION_${id}`,
  url: katelloApi.getApiUrl(`/host_collections/${id}/add_hosts`),
  params: { host_ids: hostIds },
  successToast: () => __('Hosts added successfully'),
  errorToast: error => error.response?.data?.error?.message || __('Failed to add hosts'),
  handleSuccess,
  handleError,
});

export const removeHostsFromCollection = (id, hostIds, handleSuccess) => put({
  type: API_OPERATIONS.PUT,
  key: `REMOVE_HOSTS_FROM_COLLECTION_${id}`,
  url: katelloApi.getApiUrl(`/host_collections/${id}/remove_hosts`),
  params: { host_ids: hostIds },
  successToast: () => __('Hosts removed successfully'),
  errorToast: error => error.response?.data?.error?.message || __('Failed to remove hosts'),
  handleSuccess,
});
