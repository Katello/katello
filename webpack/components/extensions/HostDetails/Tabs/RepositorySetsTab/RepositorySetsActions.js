import { translate as __ } from 'foremanReact/common/I18n';
import { API_OPERATIONS, get, put } from 'foremanReact/redux/API';
import katelloApi, { foremanApi } from '../../../../../services/api';
import { REPOSITORY_SETS_KEY, CONTENT_OVERRIDES_KEY } from './RepositorySetsConstants';
import { getResponseErrorMsgs } from '../../../../../utils/helpers';

const errorToast = (error) => {
  const message = getResponseErrorMsgs(error.response);
  return message;
};

export const getHostRepositorySets = params => get({
  type: API_OPERATIONS.GET,
  key: REPOSITORY_SETS_KEY,
  url: katelloApi.getApiUrl('/repository_sets'),
  errorToast: error => errorToast(error),
  params,
});

export const enableRepoSetRepo = ({ hostId, labels, updateResults }) => put({
  type: API_OPERATIONS.PUT,
  key: CONTENT_OVERRIDES_KEY,
  url: foremanApi.getApiUrl(`/hosts/${hostId}/subscriptions/content_override`),
  params: {
    content_overrides: labels.map(label => ({
      content_label: label,
      name: 'enabled',
      value: true,
    })),
  },
  updateData: () => {
    updateResults({ labels, enabled: true });
  },
  successToast: () => (labels.length === 1 ? __('Repository set enabled') : __('Repository sets enabled')),
  errorToast: error => errorToast(error),
});

export const disableRepoSetRepo = ({ hostId, labels, updateResults }) => put({
  type: API_OPERATIONS.PUT,
  key: CONTENT_OVERRIDES_KEY,
  url: foremanApi.getApiUrl(`/hosts/${hostId}/subscriptions/content_override`),
  params: {
    content_overrides: labels.map(label => ({
      content_label: label,
      name: 'enabled',
      value: false,
    })),
  },
  updateData: () => {
    updateResults({ labels, enabled: false });
  },
  successToast: () => (labels.length === 1 ? __('Repository set disabled') : __('Repository sets disabled')),
  errorToast: error => errorToast(error),
});

export const resetRepoSetRepo = ({ hostId, labels, updateResults }) => put({
  type: API_OPERATIONS.PUT,
  key: CONTENT_OVERRIDES_KEY,
  url: foremanApi.getApiUrl(`/hosts/${hostId}/subscriptions/content_override`),
  params: {
    content_overrides: labels.map(label => ({
      content_label: label,
      name: 'enabled',
      value: false,
      remove: true,
    })),
  },
  updateData: (_, resp) => {
    updateResults({ labels, enabled: null, newResponse: resp });
  },
  successToast: () => (labels.length === 1 ? __('Repository set reset to default') : __('Repository sets reset to default')),
  errorToast: error => errorToast(error),
});
