import { API_OPERATIONS, get, post } from 'foremanReact/redux/API';
import api, { orgId } from '../../services/api';
import SYNC_PLANS_KEY from "./SyncPlanConstants"; import CONTENT_VIEWS_KEY from "../ContentViews/ContentViewsConstants";

const createSyncPlanParams = (extraParams) => {
  const getParams = {
    organization_id: orgId(),
    include_permissions: true,
    ...extraParams,
  };
  return getParams;
};

const getSyncPlans= (extraParams, id = '') => get({
  type: API_OPERATIONS.GET,
  key: SYNC_PLANS_KEY,
  url: api.getApiUrl('/sync_plans'),
  params: createSyncPlanParams(extraParams),
});

export default getSyncPlans;