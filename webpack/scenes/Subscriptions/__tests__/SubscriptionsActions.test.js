import thunk from 'redux-thunk';
import Immutable from 'seamless-immutable';
import configureMockStore from 'redux-mock-store';
import { testActionSnapshotWithFixtures } from 'react-redux-test-utils';
import { mockRequest, mockErrorRequest, mockReset } from '../../../mockRequest';
import {
  requestSuccessResponse,
  requestSuccessResponseWithRHSubscriptions,
  successActions,
  successActionsWithQuantityLoad,
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
  handleTask,
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

import { getTaskPendingResponse, getTaskSuccessResponse } from '../../Tasks/__tests__/task.fixtures';

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

afterEach(() => {
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
    it(
      'creates SUBSCRIPTIONS_REQUEST and triggers loadAvailableQuantities when there is some RH subscription',
      async () => {
        mockRequest({
          url: '/katello/api/v2/subscriptions',
          response: requestSuccessResponseWithRHSubscriptions,
        });
        await store.dispatch(loadSubscriptions());
        expect(store.getActions()).toEqual(successActionsWithQuantityLoad);
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

  describe('handleTask', () => {
    describe('when not polling a task', () => {
      it('starts polling the task', async () => {
        await store.dispatch(handleTask(getTaskSuccessResponse));

        expect(store.getActions()).toMatchSnapshot();
      });
    });

    it('does nothing if already polling and task is pending', async () => {
      const pollStore = configureMockStore([thunk])({
        intervals: {
          SUBSCRIPTIONS_POLL_TASK: 5,
        },
      });

      await pollStore.dispatch(handleTask(getTaskPendingResponse));

      expect(pollStore.getActions()).toMatchSnapshot();
    });

    it('handles a finished task', async () => {
      const pollStore = configureMockStore([thunk])({
        intervals: {
          SUBSCRIPTIONS_POLL_TASK: 5,
        },
      });

      await pollStore.dispatch(handleTask(getTaskSuccessResponse));

      expect(pollStore.getActions()).toMatchSnapshot();
    });
  });

  describe('pollTasks', () => testActionSnapshotWithFixtures({
    'can search tasks': () => store.dispatch(pollTasks()),
  }));

  describe('cancelPollTasks', () => {
    it('cancels the tasks search', async () => {
      await store.dispatch(cancelPollTasks());

      expect(store.getActions()).toMatchSnapshot();
    });

    it('does nothing if not already polling', async () => {
      const pollStore = configureMockStore([thunk])({});

      await pollStore.dispatch(cancelPollTasks());

      expect(pollStore.getActions()).toMatchSnapshot();
    });
  });

  describe('resetTasks', () => testActionSnapshotWithFixtures({
    'resets the task state': () => resetTasks(),
  }));

  describe('deleteModal', () => testActionSnapshotWithFixtures({
    'it should open delete modal': () => openDeleteModal(),
    'it should close delete modal': () => closeDeleteModal(),
  }));

  describe('searchQuery', () => testActionSnapshotWithFixtures({
    'it should update the search-query': () => updateSearchQuery('some-query'),
  }));

  describe('deleteButtonDisabled', () => testActionSnapshotWithFixtures({
    'it should disable the delete button': () => disableDeleteButton(),
    'it should enable the delete button': () => enableDeleteButton(),
  }));
});
