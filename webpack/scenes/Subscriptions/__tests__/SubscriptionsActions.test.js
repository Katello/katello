import thunk from 'redux-thunk';
import Immutable from 'seamless-immutable';
import configureMockStore from 'redux-mock-store';
import { mockRequest, mockErrorRequest, mockReset } from '../../../mockRequest';
import {
  requestSuccessResponse,
  successActions,
  failureActions,
  updateQuantitySuccessActions,
  updateQuantityFailureActions,
  poolsUpdate,
  loadQuantitiesFailureActions,
  loadQuantitiesSuccessActions,
  quantitiesRequestSuccessResponse,
  loadTableColumnsSuccessAction,
} from './subscriptions.fixtures';
import {
  handleFinishedTask,
  handleStartTask,
  pollTasks,
  cancelPollTasks,
  resetTasks,
  loadSubscriptions,
  updateQuantity,
  loadAvailableQuantities,
  loadTableColumns,
  updateSearchQuery,
  openDeleteModal,
  closeDeleteModal,
  disableDeleteButton,
  enableDeleteButton,
} from '../SubscriptionActions';

import { getTaskSuccessResponse } from '../../Tasks/__tests__/task.fixtures';

const mockStore = configureMockStore([thunk]);
const store = mockStore(Immutable({
  intervals: {
    SUBSCRIPTIONS_TASK_SEARCH: 5,
  },
  katello: {
    subscriptions: {},
    organization: {
      id: 1,
    },
  },
}));

beforeEach(() => {
  store.clearActions();
  mockReset();
});

describe('subscription actions', () => {
  describe('loadSubscriptions', () => {
    it(
      'creates SUBSCRIPTIONS_REQUEST and then fails with 422',
      async () => {
        mockErrorRequest({
          url: '/katello/api/v2/subscriptions',
          status: 422,
        });
        await store.dispatch(loadSubscriptions());
        expect(store.getActions()).toEqual(failureActions);
      },
    );
    it(
      'creates SUBSCRIPTIONS_REQUEST and ends with success',
      async () => {
        mockRequest({
          url: '/katello/api/v2/subscriptions',
          response: requestSuccessResponse,
        });
        await store.dispatch(loadSubscriptions());
        expect(store.getActions()).toEqual(successActions);
      },
    );
  });

  describe('updateQuantity', () => {
    it(
      'creates UPDATE_QUANTITY_REQUEST and then fails with 422',
      async () => {
        mockErrorRequest({
          method: 'PUT',
          url: '/katello/api/v2/organizations/1/upstream_subscriptions',
          data: { pools: poolsUpdate },
          status: 422,
        });
        await store.dispatch(updateQuantity(poolsUpdate));
        expect(store.getActions()).toEqual(updateQuantityFailureActions);
      },
    );
    it(
      'creates UPDATE_QUANTITY_REQUEST and ends with success',
      async () => {
        mockRequest({
          method: 'PUT',
          url: '/katello/api/v2/organizations/1/upstream_subscriptions',
          data: { pools: poolsUpdate },
          response: requestSuccessResponse,
        });
        await store.dispatch(updateQuantity(poolsUpdate));
        expect(store.getActions()).toEqual(updateQuantitySuccessActions);
      },
    );
  });

  describe('loadAvailableQuantities', () => {
    const data = { pool_ids: [5] };

    it(
      'creates SUBSCRIPTIONS_QUANTITIES_REQUEST and then fails with 500',
      async () => {
        mockErrorRequest({
          method: 'GET',
          url: '/katello/api/v2/organizations/1/upstream_subscriptions',
          data,
          status: 500,
        });
        await store.dispatch(loadAvailableQuantities());
        expect(store.getActions()).toEqual(loadQuantitiesFailureActions);
      },
    );
    it(
      'creates SUBSCRIPTIONS_QUANTITIES_REQUEST and ends with success',
      async () => {
        mockRequest({
          method: 'GET',
          url: '/katello/api/v2/organizations/1/upstream_subscriptions',
          data,
          response: quantitiesRequestSuccessResponse,
        });
        await store.dispatch(loadAvailableQuantities());
        expect(store.getActions()).toEqual(loadQuantitiesSuccessActions);
      },
    );
  });
  describe('loadTableColumns', () => {
    it(
      'loads table columns',
      () => {
        store.dispatch(loadTableColumns());
        expect(store.getActions()).toEqual(loadTableColumnsSuccessAction);
      },
    );
  });

  describe('handleStartTask', () => {
    it('starts polling the task', async () => {
      await store.dispatch(handleStartTask(getTaskSuccessResponse));

      expect(store.getActions()).toEqual([
        {
          type: 'STOP_INTERVAL',
          key: 'SUBSCRIPTIONS_TASK_SEARCH',
        },
        {
          type: 'API_GET',
          interval: 5000,
          payload: {
            key: 'SUBSCRIPTIONS_POLL_TASK',
            url: `/foreman_tasks/api/tasks/${getTaskSuccessResponse.id}`,
            handleSuccess: undefined,
          },
        },
      ]);
    });
  });

  describe('handleFinishedTask', () => {
    it('handles a finished task', async () => {
      const pollStore = configureMockStore([thunk])({
        intervals: {
          SUBSCRIPTIONS_POLL_TASK: 5,
        },
      });

      await pollStore.dispatch(handleFinishedTask(getTaskSuccessResponse));

      const actions = pollStore.getActions();

      expect(actions.map(action => action.type)).toEqual([
        'STOP_INTERVAL',
        'toasts/addToast',
        'SUBSCRIPTIONS_RESET_TASKS',
        'API_GET',
        'SUBSCRIPTIONS_REQUEST',
      ]);
      expect(actions[0]).toEqual({
        type: 'STOP_INTERVAL',
        key: 'SUBSCRIPTIONS_POLL_TASK',
      });
      expect(actions[3]).toMatchObject({
        type: 'API_GET',
        interval: 5000,
        payload: {
          key: 'SUBSCRIPTIONS_TASK_SEARCH',
          url: '/foreman_tasks/api/tasks',
          params: {
            search: expect.stringContaining('organization_id=1 and result=pending'),
          },
        },
      });
    });
  });

  describe('pollTasks', () => {
    it('can search tasks', async () => {
      await store.dispatch(pollTasks());

      expect(store.getActions()).toEqual([
        {
          type: 'STOP_INTERVAL',
          key: 'SUBSCRIPTIONS_TASK_SEARCH',
        },
        {
          type: 'API_GET',
          interval: 5000,
          payload: {
            key: 'SUBSCRIPTIONS_TASK_SEARCH',
            url: '/foreman_tasks/api/tasks',
            params: {
              search: expect.stringContaining('organization_id=1 and result=pending'),
            },
          },
        },
      ]);
    });
  });

  describe('cancelPollTasks', () => {
    it('cancels the tasks search', async () => {
      await store.dispatch(cancelPollTasks());

      expect(store.getActions()).toEqual([
        {
          type: 'STOP_INTERVAL',
          key: 'SUBSCRIPTIONS_TASK_SEARCH',
        },
      ]);
    });

    it('does nothing if not already polling', async () => {
      const pollStore = configureMockStore([thunk])({});

      await pollStore.dispatch(cancelPollTasks());

      expect(pollStore.getActions()).toEqual([]);
    });
  });

  describe('resetTasks', () => {
    it('resets the task state', async () => {
      await store.dispatch(resetTasks());

      expect(store.getActions()).toEqual([{ type: 'SUBSCRIPTIONS_RESET_TASKS' }]);
    });
  });

  describe('deleteModal', () => {
    it('opens delete modal', () => {
      expect(openDeleteModal()).toEqual({ type: 'SUBSCRIPTIONS_OPEN_DELETE_MODAL' });
    });

    it('closes delete modal', () => {
      expect(closeDeleteModal()).toEqual({ type: 'SUBSCRIPTIONS_CLOSE_DELETE_MODAL' });
    });
  });

  describe('searchQuery', () => {
    it('updates the search-query', () => {
      expect(updateSearchQuery('some-query')).toEqual({
        type: 'SUBSCRIPTIONS_UPDATE_SEARCH_QUERY',
        payload: 'some-query',
      });
    });
  });

  describe('deleteButtonDisabled', () => {
    it('disables the delete button', () => {
      expect(disableDeleteButton()).toEqual({ type: 'SUBSCRIPTIONS_DISABLE_DELETE_BUTTON' });
    });

    it('enables the delete button', () => {
      expect(enableDeleteButton()).toEqual({ type: 'SUBSCRIPTIONS_ENABLE_DELETE_BUTTON' });
    });
  });
});
