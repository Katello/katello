import {
  selectSubscriptionsState,
  selectSearchQuery,
  selectDeleteModalOpened,
  selectDeleteButtonDisabled,
  selectSubscriptionsTask,
  selectHasUpstreamConnection,
} from '../SubscriptionsSelectors';

const state = {
  katello: {
    subscriptions: {
      searchQuery: 'some-query',
      deleteModalOpened: false,
      taskModalOpened: false,
      deleteButtonDisabled: true,
      hasUpstreamConnection: false,
      task: {},
    },
  },
};

describe('Subscriptions selectors', () => {
  it('selects the subscriptions state', () => {
    expect(selectSubscriptionsState(state)).toEqual(state.katello.subscriptions);
  });

  it('selects search query', () => {
    expect(selectSearchQuery(state)).toEqual('some-query');
  });

  it('selects delete modal state', () => {
    expect(selectDeleteModalOpened(state)).toBe(false);
  });

  it('selects delete button disabled flag', () => {
    expect(selectDeleteButtonDisabled(state)).toBe(true);
  });

  it('selects current task', () => {
    expect(selectSubscriptionsTask(state)).toEqual({});
  });

  it('selects upstream connection flag', () => {
    expect(selectHasUpstreamConnection(state)).toBe(false);
  });
});
