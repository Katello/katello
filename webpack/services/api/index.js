import axios from 'axios';
import Immutable from 'seamless-immutable';

const getcsrfToken = () => {
  const token = document.querySelector('meta[name="csrf-token"]');
  return token ? token.content : '';
};

axios.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';
axios.defaults.headers.common['X-CSRF-Token'] = getcsrfToken();

const addBaseApiPath = url => `/katello/api/v2${url}`;

export const initialApiState = Immutable({
  loading: true,
  pagination: {
    page: 0,
    perPage: 20,
  },
  itemCount: 0,
  results: [],
});

export default {
  get(url, headers = {}, params = {}) {
    return axios.get(addBaseApiPath(url), {
      headers,
      params,
    });
  },
  put(url, data = {}, headers = {}) {
    return axios.put(addBaseApiPath(url), data, {
      headers,
    });
  },
  post(url, data = {}, headers = {}) {
    return axios.post(addBaseApiPath(url), data, {
      headers,
    });
  },
  delete(url, headers = {}) {
    return axios.delete(addBaseApiPath(url), {
      headers,
    });
  },
  patch(url, data = {}, headers = {}) {
    return axios.patch(addBaseApiPath(url), data, {
      headers,
    });
  },
};

// eslint-disable-next-line import/prefer-default-export
const orgNode = document.getElementById('organization-id');
// This node does not exist while testing
export const orgId = orgNode ? orgNode.dataset.id : '1';
