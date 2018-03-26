import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import thunk from 'redux-thunk';
import Immutable from 'seamless-immutable';
import configureMockStore from 'redux-mock-store';
import {
  bulkSearchSuccessResponse,
  bulkSearchSuccessActions,
  bulkSearchFailureActions,
  getTaskSuccessResponse,
  getTaskSuccessActions,
  getTaskFailureActions,
} from './task.fixtures';

import { bulkSearch, loadTask, pollTaskUntilDone } from '../TaskActions';

const mockStore = configureMockStore([thunk]);
const store = mockStore({ tasks: Immutable({}) });
const mockApi = new MockAdapter(axios);

beforeEach(() => {
  store.clearActions();
  mockApi.reset();
});

let originalTimeout;

beforeEach(() => {
  originalTimeout = jasmine.DEFAULT_TIMEOUT_INTERVAL;
  jasmine.DEFAULT_TIMEOUT_INTERVAL = 10000;
});

afterEach(() => {
  jasmine.DEFAULT_TIMEOUT_INTERVAL = originalTimeout;
});

describe('task actions', () => {
  describe('creates TASK_BULK_SEARCH_REQUEST', () => {
    const url = '/foreman_tasks/api/tasks/bulk_search';

    it('and then fails with 422', () => {
      mockApi.onPost(url).reply(422);

      return store.dispatch(bulkSearch())
        .then(() => expect(store.getActions()).toEqual(bulkSearchFailureActions));
    });

    it('and ends with success', () => {
      mockApi.onPost(url).reply(200, bulkSearchSuccessResponse);

      return store.dispatch(bulkSearch())
        .then(() => expect(store.getActions()).toEqual(bulkSearchSuccessActions));
    });
  });

  describe('creates GET_TASK_REQUEST', () => {
    const taskId = 'eb1b6271-8a69-4d98-84fc-bea06ddcc166';
    const url = `/foreman_tasks/api/tasks/${taskId}`;

    it('and then fails with 422', () => {
      mockApi.onGet(url).reply(422);

      return store.dispatch(loadTask(taskId))
        .then(() => expect(store.getActions()).toEqual(getTaskFailureActions));
    });

    it('and ends with success', () => {
      mockApi.onGet(url).reply(200, getTaskSuccessResponse);

      return store.dispatch(loadTask(taskId))
        .then(() => expect(store.getActions()).toEqual(getTaskSuccessActions));
    });

    it('and can poll', () => {
      mockApi.onGet(url).reply(200, getTaskSuccessResponse);

      return store.dispatch(pollTaskUntilDone(taskId))
        .then(() => expect(store.getActions()).toEqual(getTaskSuccessActions));
    });
  });
});
