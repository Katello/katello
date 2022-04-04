import { translate as __ } from 'foremanReact/common/I18n';
import { API_OPERATIONS, get, post } from 'foremanReact/redux/API';
import api, { orgId } from '../../services/api';
import CONTENT_VIEWS_KEY, {
  CREATE_CONTENT_VIEW_KEY, COPY_CONTENT_VIEW_KEY,
  cvVersionPublishKey,
} from './ContentViewsConstants';
import { getResponseErrorMsgs } from '../../utils/helpers';
import { renderTaskStartedToast } from '../Tasks/helpers';

export const createContentViewsParams = (extraParams) => {
  const getParams = {
    organization_id: orgId(),
    nondefault: true,
    include_permissions: true,
    ...extraParams,
  };
  if (extraParams?.include_default) delete getParams.nondefault;
  return getParams;
};

const getContentViews = (extraParams, id = '') => get({
  type: API_OPERATIONS.GET,
  key: CONTENT_VIEWS_KEY + id,
  url: api.getApiUrl('/content_views'),
  params: createContentViewsParams(extraParams),
});

const cvSuccessToast = (response) => {
  const { data: { name } } = response;
  return __(`Content view ${name} created`);
};

export const cvErrorToast = (error) => {
  const message = getResponseErrorMsgs(error.response);
  return message;
};

export const createContentView = params => post({
  type: API_OPERATIONS.POST,
  key: CREATE_CONTENT_VIEW_KEY,
  url: api.getApiUrl('/content_views'),
  params,
  successToast: response => cvSuccessToast(response),
  errorToast: error => cvErrorToast(error),
});

export const copyContentView = params => post({
  type: API_OPERATIONS.POST,
  key: COPY_CONTENT_VIEW_KEY,
  url: api.getApiUrl(`/content_views/${params.id}/copy`),
  params,
  successToast: response => cvSuccessToast(response),
  errorToast: error => cvErrorToast(error),
});

export const publishContentView = (params, handleSuccess, handleError) => post({
  type: API_OPERATIONS.POST,
  key: cvVersionPublishKey(params.id, params.versionCount),
  url: api.getApiUrl(`/content_views/${params.id}/publish`),
  params,
  handleSuccess: (response) => {
    if (handleSuccess) handleSuccess(response);
    return renderTaskStartedToast(response.data);
  },
  handleError,
  errorToast: error => cvErrorToast(error),
});


export default getContentViews;
