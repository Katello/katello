import axios from 'axios';
import Immutable from 'seamless-immutable';
import store from 'foremanReact/redux';

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

  // Use for endpoints that return a file to download
  open(url, params) {
    window.location.href = this.getApiUrl(url) + this.createUrlParams(params);
  }

  /* eslint-disable class-methods-use-this */
  createUrlParams(params) {
    // eslint-disable-next-line translation/no-strings-without-translations
    let urlParams = '?';
    Object.keys(params).forEach((key) => {
      if (urlParams !== '?') {
        urlParams += '&';
      }
      urlParams += `${key}=${encodeURIComponent(params[key])}`;
    });
    return urlParams;
  }
  /* eslint-enable class-methods-use-this */
}

export default new Api();

class ForemanApi extends Api {
  constructor() {
    super();
    this.baseApiPath = '/api/v2';
  }
}

export const foremanApi = new ForemanApi();

class ForemanTasksApi extends Api {
  constructor() {
    super();
    this.baseApiPath = '/foreman_tasks/api';
  }
}

export const foremanTasksApi = new ForemanTasksApi();

class ForemanEndpoint extends Api {
  constructor() {
    super();
    this.baseApiPath = '/';
  }
}

export const foremanEndpoint = new ForemanEndpoint();

// eslint-disable-next-line import/prefer-default-export
const orgNode = () => document.getElementById('organization-id');
const userNode = () => document.getElementById('user-id');
// This node does not exist while testing
export const orgId = () => {
  const node = orgNode();
  const id = node && node.dataset.id;
  const { katello: { setOrganization: { currentId } } } = store.getState();

  return id === '' ? currentId : id;
};

export const userId = () => (userNode() ? userNode().dataset.id : '1');
