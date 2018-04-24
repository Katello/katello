import axios from 'axios';
import Immutable from 'seamless-immutable';

const getcsrfToken = () => {
  const token = document.querySelector('meta[name="csrf-token"]');
  return token ? token.content : '';
};

axios.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';
axios.defaults.headers.common['X-CSRF-Token'] = getcsrfToken();

export const initialApiState = Immutable({
  loading: true,
  pagination: {
    page: 0,
    perPage: 20,
  },
  itemCount: 0,
  results: [],
});

class Api {
  constructor() {
    this.baseApiPath = '/katello/api/v2';
  }

  getApiUrl(url) {
    return this.baseApiPath + url;
  }

  get(url, headers = {}, params = {}) {
    return axios.get(this.getApiUrl(url), {
      headers,
      params,
    });
  }

  put(url, data = {}, headers = {}) {
    return axios.put(this.getApiUrl(url), data, {
      headers,
    });
  }

  post(url, data = {}, headers = {}) {
    return axios.post(this.getApiUrl(url), data, {
      headers,
    });
  }

  delete(url, headers = {}, data = {}) {
    return axios.delete(this.getApiUrl(url), {
      headers,
      data,
    });
  }

  patch(url, data = {}, headers = {}) {
    return axios.patch(this.getApiUrl(url), data, {
      headers,
    });
  }
}

export default new Api();

class ForemanTasksApi extends Api {
  constructor() {
    super();
    this.baseApiPath = '/foreman_tasks/api';
  }
}

export const foremanTasksApi = new ForemanTasksApi();

// eslint-disable-next-line import/prefer-default-export
const orgNode = document.getElementById('organization-id');
// This node does not exist while testing
export const orgId = orgNode ? orgNode.dataset.id : '1';
