import { API_OPERATIONS, get } from 'foremanReact/redux/API';
import api, { orgId } from '../../services/api';
import CONTENT_VIEWS_KEY from './ContentViewsConstants';


const createContentViewsParams = () => ({
  organization_id: orgId(),
  nondefault: true,
});

const getContentViews = () => get({
  type: API_OPERATIONS.GET,
  key: CONTENT_VIEWS_KEY,
  url: api.getApiUrl('/content_views'),
  params: createContentViewsParams(),
});

export default getContentViews;
