import {
  SUBSCRIPTIONS_SUCCESS,
  SUBSCRIPTIONS_FAILURE,
  SUBSCRIPTIONS_COLUMNS_REQUEST,
  UPDATE_SUBSCRIPTION_COLUMNS,
  SUBSCRIPTIONS_QUANTITIES_REQUEST,
  SUBSCRIPTIONS_QUANTITIES_SUCCESS,
  SUBSCRIPTIONS_QUANTITIES_FAILURE,
  UPDATE_QUANTITY_REQUEST,
  UPDATE_QUANTITY_SUCCESS,
  UPDATE_QUANTITY_FAILURE,
  DELETE_SUBSCRIPTIONS_REQUEST,
  DELETE_SUBSCRIPTIONS_SUCCESS,
  SUBSCRIPTIONS_UPDATE_SEARCH_QUERY,
  SUBSCRIPTIONS_OPEN_DELETE_MODAL,
  SUBSCRIPTIONS_CLOSE_DELETE_MODAL,
  SUBSCRIPTIONS_DISABLE_DELETE_BUTTON,
  SUBSCRIPTIONS_ENABLE_DELETE_BUTTON,
  SUBSCRIPTIONS_RESET_TASKS,
  SUBSCRIPTIONS_TASK_SEARCH_SUCCESS,
  SUBSCRIPTIONS_TASK_SEARCH_FAILURE,
  SUBSCRIPTIONS_POLL_TASK_SUCCESS,
  SUBSCRIPTIONS_POLL_TASK_FAILURE,
} from '../SubscriptionConstants';
import reducer from '../SubscriptionReducer';

import {
  DELETE_MANIFEST_SUCCESS,
  UPLOAD_MANIFEST_SUCCESS,
  REFRESH_MANIFEST_SUCCESS,
} from '../Manifest/ManifestConstants';

const mockTask = {
  id: '12345',
  humanized: {
    action: 'ManifestRefresh',
  },
};

const anotherMockTask = {
  id: '54321',
  humanized: {
    action: 'ManifestDelete',
  },
};

describe('Subscriptions reducer', () => {
  it('returns the initial state', () => {
    const state = reducer(undefined, {});

    expect(state.loading).toBe(true);
    expect(state.task).toBeNull();
    expect(state.searchQuery).toBe('');
    expect(state.deleteModalOpened).toBe(false);
    expect(state.deleteButtonDisabled).toBe(true);
  });

  it('handles SUBSCRIPTIONS_SUCCESS', () => {
    const state = reducer(undefined, {
      type: SUBSCRIPTIONS_SUCCESS,
      response: {
        page: 1,
        per_page: 10, // eslint-disable-line camelcase
        subtotal: 20,
        results: 'some-results',
      },
      search: 'some search',
    });

    expect(state.loading).toBe(false);
    expect(state.results).toEqual('some-results');
    expect(state.search).toEqual('some search');
    expect(state.searchIsActive).toBe(true);
    expect(state.itemCount).toBe(20);
    expect(state.pagination).toEqual({ page: 1, perPage: 10 });
  });

  it('handles SUBSCRIPTIONS_FAILURE with explicit missing permissions', () => {
    const state = reducer(undefined, {
      type: SUBSCRIPTIONS_FAILURE,
      payload: {
        messages: [{ missing_permissions: ['view_subscriptions'] }],
      },
    });

    expect(state.loading).toBe(false);
    expect(state.results).toEqual([]);
    expect(state.itemCount).toBe(0);
    expect(state.missingPermissions).toEqual(['view_subscriptions']);
  });

  it('handles SUBSCRIPTIONS_FAILURE with 403/404 fallback permissions', () => {
    const state = reducer(undefined, {
      type: SUBSCRIPTIONS_FAILURE,
      payload: {
        result: {
          response: {
            status: 403,
          },
        },
        messages: ['forbidden'],
      },
    });

    expect(state.missingPermissions).toEqual(['forbidden']);
  });

  it('handles quantities request lifecycle', () => {
    const loadingState = reducer(undefined, {
      type: SUBSCRIPTIONS_QUANTITIES_REQUEST,
    });
    expect(loadingState.quantitiesLoading).toBe(true);
    expect(loadingState.availableQuantities).toBeNull();

    const successState = reducer(loadingState, {
      type: SUBSCRIPTIONS_QUANTITIES_SUCCESS,
      payload: { 1: 5 },
    });
    expect(successState.quantitiesLoading).toBe(false);
    expect(successState.availableQuantities).toEqual({ 1: 5 });

    const failedState = reducer(loadingState, {
      type: SUBSCRIPTIONS_QUANTITIES_FAILURE,
    });
    expect(failedState.quantitiesLoading).toBe(false);
    expect(failedState.availableQuantities).toEqual({});
  });

  it('handles table column updates', () => {
    const selectedColumnsState = reducer(undefined, {
      type: UPDATE_SUBSCRIPTION_COLUMNS,
      payload: {
        enabledColumns: ['col1', 'col2'],
      },
    });
    expect(selectedColumnsState.selectedTableColumns).toEqual(['col1', 'col2']);

    const columnsState = reducer(selectedColumnsState, {
      type: SUBSCRIPTIONS_COLUMNS_REQUEST,
      payload: {
        tableColumns: ['col1', 'col2', 'col3'],
      },
    });
    expect(columnsState.tableColumns).toEqual(['col1', 'col2', 'col3']);
  });

  it('tracks manifest-related task lifecycle', () => {
    const requestState = reducer(undefined, { type: UPDATE_QUANTITY_REQUEST });
    expect(requestState.manifestActionStarted).toBe(true);

    const successState = reducer(requestState, {
      type: UPDATE_QUANTITY_SUCCESS,
      response: mockTask,
    });
    expect(successState.manifestActionStarted).toBe(false);
    expect(successState.task).toEqual(mockTask);

    const failedState = reducer(requestState, { type: UPDATE_QUANTITY_FAILURE });
    expect(failedState.manifestActionStarted).toBe(false);
  });

  it('tracks task search and reset actions', () => {
    const taskState = reducer(undefined, {
      type: SUBSCRIPTIONS_TASK_SEARCH_SUCCESS,
      response: {
        results: [mockTask, anotherMockTask],
      },
    });
    expect(taskState.task).toEqual(mockTask);

    const existingTaskState = reducer(taskState, {
      type: SUBSCRIPTIONS_TASK_SEARCH_SUCCESS,
      response: {
        results: [anotherMockTask],
      },
    });
    expect(existingTaskState.task).toEqual(mockTask);

    const pollingState = reducer(taskState, {
      type: SUBSCRIPTIONS_POLL_TASK_SUCCESS,
      response: anotherMockTask,
    });
    expect(pollingState.task).toEqual(anotherMockTask);

    expect(reducer(taskState, { type: SUBSCRIPTIONS_RESET_TASKS }).task).toBeNull();
    expect(reducer(taskState, { type: SUBSCRIPTIONS_TASK_SEARCH_FAILURE }).task).toBeNull();
    expect(reducer(taskState, { type: SUBSCRIPTIONS_POLL_TASK_FAILURE }).task).toBeNull();
  });

  it('handles delete/update modal and button actions', () => {
    const openedState = reducer(undefined, { type: SUBSCRIPTIONS_OPEN_DELETE_MODAL });
    expect(openedState.deleteModalOpened).toBe(true);

    const closedState = reducer(openedState, { type: SUBSCRIPTIONS_CLOSE_DELETE_MODAL });
    expect(closedState.deleteModalOpened).toBe(false);

    const enabledState = reducer(undefined, { type: SUBSCRIPTIONS_ENABLE_DELETE_BUTTON });
    expect(enabledState.deleteButtonDisabled).toBe(false);

    const disabledState = reducer(enabledState, { type: SUBSCRIPTIONS_DISABLE_DELETE_BUTTON });
    expect(disabledState.deleteButtonDisabled).toBe(true);
  });

  it('handles subscription deletion and search query updates', () => {
    const deleteRequestState = reducer(undefined, { type: DELETE_SUBSCRIPTIONS_REQUEST });
    expect(deleteRequestState.manifestActionStarted).toBe(true);

    const deleteSuccessState = reducer(deleteRequestState, {
      type: DELETE_SUBSCRIPTIONS_SUCCESS,
      response: mockTask,
    });
    expect(deleteSuccessState.task).toEqual(mockTask);
    expect(deleteSuccessState.manifestActionStarted).toBe(false);
    expect(deleteSuccessState.deleteButtonDisabled).toBe(true);

    const queryState = reducer(undefined, {
      type: SUBSCRIPTIONS_UPDATE_SEARCH_QUERY,
      payload: 'some-query',
    });
    expect(queryState.searchQuery).toEqual('some-query');
  });

  it('handles manifest success actions', () => {
    const deleteManifestState = reducer(undefined, {
      type: DELETE_MANIFEST_SUCCESS,
      response: mockTask,
    });
    expect(deleteManifestState.task).toEqual(mockTask);
    expect(deleteManifestState.hasUpstreamConnection).toBe(false);
    expect(deleteManifestState.manifestActionStarted).toBe(false);

    const uploadState = reducer(undefined, {
      type: UPLOAD_MANIFEST_SUCCESS,
      response: mockTask,
    });
    expect(uploadState.task).toEqual(mockTask);

    const refreshState = reducer(undefined, {
      type: REFRESH_MANIFEST_SUCCESS,
      response: mockTask,
    });
    expect(refreshState.task).toEqual(mockTask);
  });
});
