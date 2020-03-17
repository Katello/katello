import { API_OPERATIONS, get } from 'foremanReact/redux/API';

import CONTENT_VIEWS_KEY from '../ContentViewsConstants';

const getContentViewDetails = cvId => get({
  type: API_OPERATIONS.GET,
  key: `${CONTENT_VIEWS_KEY}_${cvId}`,
  url: `/katello/api/content_views/${cvId}`,
  params: {},
});

export default getContentViewDetails;
