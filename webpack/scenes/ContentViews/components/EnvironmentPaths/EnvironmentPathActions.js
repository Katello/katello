import { API_OPERATIONS, get } from 'foremanReact/redux/API';
import api, { orgId } from '../../../../services/api';
import { ENVIRONMENT_PATHS_KEY } from './EnvironmentPathConstants';


const getEnvironmentPaths = () => get({
  type: API_OPERATIONS.GET,
  key: ENVIRONMENT_PATHS_KEY,
  url: api.getApiUrl(`/organizations/${orgId()}/environments/paths?permission_type=promotable`),
});

export default getEnvironmentPaths;
