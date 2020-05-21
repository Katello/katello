import { API_OPERATIONS, get } from 'foremanReact/redux/API';
import api, { orgId } from '../../services/api';
import CONTENT_VIEWS_KEY from './ContentViewsConstants';

export const createContentViewsParams = extraParams => ({
  organization_id: orgId(),
  nondefault: true,
  ...extraParams,
});

const getContentViews = extraParams => get({
  type: API_OPERATIONS.GET,
  key: CONTENT_VIEWS_KEY,
  url: api.getApiUrl('/content_views'),
  params: createContentViewsParams(extraParams),
});

export default getContentViews;
