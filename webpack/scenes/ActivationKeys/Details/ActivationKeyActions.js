import { translate as __ } from 'foremanReact/common/I18n';
import { APIActions, API_OPERATIONS, put, get } from 'foremanReact/redux/API';
import { errorToast } from '../../Tasks/helpers';
import katelloApi from '../../../services/api/index';
import { ACTIVATION_KEY } from './ActivationKeyConstants';

export const getActivationKey = akId => get({
  type: API_OPERATIONS.GET,
  key: `${ACTIVATION_KEY}_${akId}`,
  url: katelloApi.getApiUrl(`/activation_keys/${akId}`),
});

export const putActivationKey = (akId, params) => put({
  type: API_OPERATIONS.PUT,
  key: `${ACTIVATION_KEY}_${akId}`,
  url: katelloApi.getApiUrl(`/activation_keys/${akId}`),
  successToast: () => __('Activation key details updated'),
  errorToast,
  params,
});

export const deleteActivationKey = akId => APIActions.delete({
  type: API_OPERATIONS.DELETE,
  key: `${ACTIVATION_KEY}_${akId}`,
  url: katelloApi.getApiUrl(`/activation_keys/${akId}`),
  successToast: () => __('Activation key deleted'),
  errorToast,
});

export default getActivationKey;
