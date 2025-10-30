import { API_OPERATIONS, get } from 'foremanReact/redux/API';
import api, { orgId } from '../../../../services/api';

export const DOCKER_TAG_DETAILS_KEY = 'DOCKER_TAG_DETAILS';

export const dockerTagDetailsKey = id => `${DOCKER_TAG_DETAILS_KEY}_${id}`;

const getDockerTagDetails = (id, extraParams = {}) => get({
  type: API_OPERATIONS.GET,
  key: dockerTagDetailsKey(id),
  params: { organization_id: orgId(), ...extraParams },
  url: api.getApiUrl(`/docker_tags/${id}`),
});

export default getDockerTagDetails;
