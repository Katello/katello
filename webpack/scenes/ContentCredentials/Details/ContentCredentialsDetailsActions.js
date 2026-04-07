import { API_OPERATIONS, get } from 'foremanReact/redux/API';
import { addToast } from 'foremanReact/components/ToastsList';
import { translate as __ } from 'foremanReact/common/I18n';
import api, { orgId } from '../../../services/api';
import { getResponseErrorMsgs } from '../../../utils/helpers';

export const CONTENT_CREDENTIAL_DETAILS_KEY = 'CONTENT_CREDENTIAL_DETAILS';
export const contentCredentialDetailsKey = credentialId => `${CONTENT_CREDENTIAL_DETAILS_KEY}_${credentialId}`;
export const UPDATE_CONTENT_CREDENTIAL_KEY = 'UPDATE_CONTENT_CREDENTIAL';
export const UPLOAD_CONTENT_CREDENTIAL_CONTENT_KEY = 'UPLOAD_CONTENT_CREDENTIAL_CONTENT';

export const getContentCredentialDetails = credentialId => get({
  type: API_OPERATIONS.GET,
  key: contentCredentialDetailsKey(credentialId),
  url: api.getApiUrl(`/content_credentials/${credentialId}`),
  params: {
    organization_id: orgId(),
  },
});

export const updateContentCredential = (credentialId, params) => async (dispatch) => {
  try {
    // Update the credential
    const response = await api.put(`/content_credentials/${credentialId}`, {
      organization_id: orgId(),
      ...params,
    });

    // Show success notification
    dispatch(addToast({
      type: 'success',
      message: __('Content credential updated successfully.'),
      key: `credential-update-success-${credentialId}`,
    }));

    // Refetch the details to get updated content
    dispatch(getContentCredentialDetails(credentialId));

    return response;
  } catch (error) {
    // Show error notification
    const errorMessage = error?.response?.data?.displayMessage ||
                         error?.response?.data?.message ||
                         error?.message ||
                         __('Failed to update content credential.');
    dispatch(addToast({
      type: 'danger',
      message: errorMessage,
      key: `credential-update-error-${credentialId}`,
    }));

    throw error;
  }
};

export const uploadContentCredentialContent = (credentialId, file) => {
  const formData = new FormData();
  formData.append('content', file);
  formData.append('organization_id', orgId());

  return async (dispatch) => {
    try {
      // Upload the file
      const uploadResponse = await api.post(`/content_credentials/${credentialId}/content`, formData);

      // Show success notification FIRST (following established codebase pattern)
      dispatch(addToast({
        type: 'success',
        message: __('Content credential file uploaded successfully.'),
        key: `credential-upload-success-${credentialId}`,
      }));

      // Then refetch the details to get updated content
      dispatch(getContentCredentialDetails(credentialId));

      return uploadResponse;
    } catch (error) {
      // Show error notification
      const [errorMessage] = getResponseErrorMsgs(error.response)
        .filter(Boolean);
      const fallbackMessage = errorMessage || __('Failed to upload content credential file.');
      dispatch(addToast({
        type: 'danger',
        message: fallbackMessage,
        key: `credential-upload-error-${credentialId}`,
      }));

      throw error;
    }
  };
};

export default getContentCredentialDetails;
