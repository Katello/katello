import HOST_DETAILS_KEY from './HostDetailsConstants';

const hostIdNotReady = { type: 'NOOP_HOST_ID_NOT_READY' };

export const getHostDetails = ({ hostname }) => ({
  type: 'API_GET',
  payload: {
    key: HOST_DETAILS_KEY,
    url: `/api/hosts/${hostname}`,
  },
});

export default hostIdNotReady;
