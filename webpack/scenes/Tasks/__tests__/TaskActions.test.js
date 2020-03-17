import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import thunk from 'redux-thunk';
import Immutable from 'seamless-immutable';
import configureMockStore from 'redux-mock-store';
import {
  bulkSearchCancelledActions,
  bulkSearchSkippedActions,
  bulkSearchSuccessResponse,
  bulkSearchSuccessActions,
  buildBulkSearchFailureActions,
  getTaskSuccessResponse,
  getPollTaskSuccessActions,
  getTaskSuccessActions,
  buildTaskFailureActions,
  getTaskPendingResponse,
  getTaskPendingActions,
  pollTaskStartedActions,
} from './task.fixtures';

import { bulkSearch, loadTask, pollTaskUntilDone, pollBulkSearch } from '../TaskActions';

const mockStore = configureMockStore([thunk]);
const store = mockStore({
  tasks: Immutable({}),
  katello: { organization: { id: 1, loading: false } },
});
const mockApi = new MockAdapter(axios);

beforeEach(() => {
  store.clearActions();
  mockApi.reset();
});

let originalTimeout;
let setTimeoutSpy;

beforeEach(() => {
  setTimeoutSpy = jest.spyOn(window, 'setTimeout');

  originalTimeout = jasmine.DEFAULT_TIMEOUT_INTERVAL;
  jasmine.DEFAULT_TIMEOUT_INTERVAL = 10000;
});

afterEach(() => {
  setTimeoutSpy.mockReset();
  setTimeoutSpy.mockRestore();

  jasmine.DEFAULT_TIMEOUT_INTERVAL = originalTimeout;
});

describe('task actions', () => {
  describe('creates TASK_BULK_SEARCH_REQUEST', () => {
    const url = '/foreman_tasks/api/tasks';

    it('and then fails with 422', async () => {
      mockApi.onGet(url).reply(422);

      await store.dispatch(bulkSearch());
      expect(store.getActions()).toEqual(buildBulkSearchFailureActions());
    });

    it('and ends with success', async () => {
      mockApi.onGet(url).reply(200, bulkSearchSuccessResponse);

      await store.dispatch(bulkSearch());
      expect(store.getActions()).toEqual(bulkSearchSuccessActions);
    });
  });

  describe('creates GET_TASK_REQUEST', () => {
    const taskId = 'eb1b6271-8a69-4d98-84fc-bea06ddcc166';
    const url = `/foreman_tasks/api/tasks/${taskId}`;

    it('and then fails with 422', async () => {
      mockApi.onGet(url).reply(422);

      await store.dispatch(loadTask(taskId));
      expect(store.getActions()).toEqual(buildTaskFailureActions());
    });

    it('and ends with success', async () => {
      mockApi.onGet(url).reply(200, getTaskSuccessResponse);

      await store.dispatch(loadTask(taskId));
      expect(store.getActions()).toEqual(getTaskSuccessActions);
    });
  });

  describe('pollTaskUntilDone', () => {
    const taskId = 'eb1b6271-8a69-4d98-84fc-bea06ddcc166';
    const url = `/foreman_tasks/api/tasks/${taskId}`;

    it("doesn't start polling when the task has finished", async () => {
      mockApi.onGet(url).replyOnce(200, getTaskSuccessResponse);

      await store.dispatch(pollTaskUntilDone(taskId, {}, 1, 1));
      expect(store.getActions()).toEqual(getPollTaskSuccessActions);
      expect(setTimeoutSpy).toHaveBeenCalledTimes(0);
    });

    it('polls until a task is done', async () => {
      mockApi
        .onGet(url)
        .replyOnce(200, getTaskPendingResponse)
        .onGet(url)
        .replyOnce(200, getTaskPendingResponse)
        .onGet(url)
        .replyOnce(200, getTaskSuccessResponse);

      const expectedActions = pollTaskStartedActions
        .concat(getTaskPendingActions)
        .concat(getTaskPendingActions)
        .concat(getTaskSuccessActions);

      await store.dispatch(pollTaskUntilDone(taskId, {}, 1, 1));
      expect(store.getActions()).toEqual(expectedActions);
      expect(setTimeoutSpy).toHaveBeenCalledTimes(2);
    });

    it('stops polling on unauthorized response', async () => {
      mockApi
        .onGet(url).replyOnce(200, getTaskPendingResponse)
        .onGet(url).replyOnce(401);

      const expectedActions = pollTaskStartedActions
        .concat(getTaskPendingActions)
        .concat(buildTaskFailureActions(401));

      try {
        await store.dispatch(pollTaskUntilDone(taskId, {}, 1, 1));
      } catch (e) {
        expect(store.getActions()).toEqual(expectedActions);
        expect(setTimeoutSpy).toHaveBeenCalledTimes(1);
      }
    });
  });

  describe('pollBulkSearch', () => {
    const url = '/foreman_tasks/api/tasks';

    it('polls', async () => {
      mockApi
        .onGet(url)
        .replyOnce(200, bulkSearchSuccessResponse);

      await store.dispatch(pollBulkSearch({}, 1, 1));
      expect(setTimeoutSpy).toHaveBeenCalledTimes(1);
      expect(store.getActions()).toEqual(bulkSearchSuccessActions);
    });

    it('stops polling on unauthorized response', async () => {
      mockApi
        .onGet(url).replyOnce(401);

      await store.dispatch(pollBulkSearch({}, 1, 1));
      expect(store.getActions()).toEqual(buildBulkSearchFailureActions(401));
      expect(setTimeoutSpy).toHaveBeenCalledTimes(0);
    });

    it('stops polling when cancelled', async () => {
      mockApi
        .onGet(url)
        .replyOnce(200, bulkSearchSuccessResponse)
        .onGet(url)
        .replyOnce(200, bulkSearchSuccessResponse);

      const expectedActions = bulkSearchSuccessActions
        .concat(bulkSearchSuccessActions)
        .concat(bulkSearchCancelledActions);

      let counter = 0;
      const cancelFunc = () => {
        counter += 1;
        return counter > 2;
      };

      await store.dispatch(pollBulkSearch({}, 1, 1, null, cancelFunc));
      await store.dispatch(pollBulkSearch({}, 1, 1, null, cancelFunc));
      await store.dispatch(pollBulkSearch({}, 1, 1, null, cancelFunc)); // cancelled by this point
      expect(setTimeoutSpy).toHaveBeenCalledTimes(2);
      expect(store.getActions()).toEqual(expectedActions);
    });

    it('can skip polling', async () => {
      mockApi
        .onGet(url)
        .replyOnce(200, bulkSearchSuccessResponse)
        .onGet(url)
        .replyOnce(200, bulkSearchSuccessResponse);

      const expectedActions = bulkSearchSuccessActions
        .concat(bulkSearchSkippedActions)
        .concat(bulkSearchSuccessActions);

      let counter = 0;
      const skipFunc = () => {
        counter += 1;
        return counter === 2;
      };

      await store.dispatch(pollBulkSearch({}, 1, 1, skipFunc));
      await store.dispatch(pollBulkSearch({}, 1, 1, skipFunc)); // this one is skipped
      await store.dispatch(pollBulkSearch({}, 1, 1, skipFunc));
      expect(setTimeoutSpy).toHaveBeenCalledTimes(3);
      expect(store.getActions()).toEqual(expectedActions);
    });
  });
});
