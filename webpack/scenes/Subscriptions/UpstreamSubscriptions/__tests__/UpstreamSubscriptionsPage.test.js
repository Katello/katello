import React from 'react';
import userEvent from '@testing-library/user-event';
import { screen } from '@testing-library/react';
import { Router } from 'react-router-dom';
import { createMemoryHistory } from 'history';
import { rtlHelpers } from 'foremanReact/common/rtlTestHelpers';
import { STATUS } from 'foremanReact/constants';
import { APIActions } from 'foremanReact/redux/API';
import { patientlyWaitFor } from 'react-testing-lib-wrapper';
import UpstreamSubscriptionsPage from '../UpstreamSubscriptionsPage';
import api from '../../../../services/api';
import { nockInstance, assertNockRequest } from '../../../../test-utils/nockWrapper';
import {
  emptyListResponse,
  requestSuccessResponse,
  taskSuccessResponse,
} from './upstreamSubscriptions.fixtures';
import {
  UPSTREAM_SUBSCRIPTIONS_KEY,
} from '../UpstreamSubscriptionsConstants';

// Katello's global EmptyState mock renders props as JSON instead of real UI.
// Use the Foreman DefaultEmptyState here so empty-state tests assert user-visible content.
jest.mock('foremanReact/components/common/EmptyState', () =>
  jest.requireActual('foremanReact/components/common/EmptyState/DefaultEmptyState'));

const { renderWithStore } = rtlHelpers;

const upstreamSubscriptionsPath = api.getApiUrl('/organizations/1/upstream_subscriptions');

const renderUpstreamSubscriptionsPage = (history = createMemoryHistory({ initialEntries: ['/'] })) => ({
  history,
  ...renderWithStore(
    <Router history={history}>
      <UpstreamSubscriptionsPage />
    </Router>,
    {
      API: {
        [UPSTREAM_SUBSCRIPTIONS_KEY]: { response: {}, status: STATUS.PENDING },
      },
    },
  ),
});

const mockListRequest = (response = requestSuccessResponse) => {
  nockInstance
    .get(upstreamSubscriptionsPath)
    .query(true)
    .reply(200, response)
    .persist();
};

const waitForSubscriptionsTable = async () => {
  await patientlyWaitFor(() => {
    expect(screen.getByText(requestSuccessResponse.results[0].product_name)).toBeInTheDocument();
  });
};

describe('upstream subscriptions page', () => {
  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('loads and renders upstream subscriptions', async () => {
    mockListRequest();

    renderUpstreamSubscriptionsPage();
    await waitForSubscriptionsTable();

    expect(screen.getByRole('button', { name: 'Submit' })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Cancel' })).toBeInTheDocument();
    expect(screen.getByText('Subscriptions')).toBeInTheDocument();
    expect(screen.getAllByText('Add Subscriptions').length).toBeGreaterThan(0);
  });

  it('disables submit button when no rows are selected', async () => {
    mockListRequest();

    renderUpstreamSubscriptionsPage();
    await waitForSubscriptionsTable();

    expect(screen.getByRole('button', { name: 'Submit' })).toBeDisabled();
  });

  it('enables submit button when a valid quantity is entered', async () => {
    mockListRequest();

    renderUpstreamSubscriptionsPage();
    await waitForSubscriptionsTable();

    await userEvent.type(screen.getAllByLabelText('Number to Allocate')[0], '5');

    await patientlyWaitFor(() => {
      expect(screen.getByRole('button', { name: 'Submit' })).toBeEnabled();
    });
  });

  it('shows inline validation error for an invalid quantity', async () => {
    mockListRequest();

    renderUpstreamSubscriptionsPage();
    await waitForSubscriptionsTable();

    await userEvent.type(screen.getAllByLabelText('Number to Allocate')[0], '101');

    await patientlyWaitFor(() => {
      expect(screen.getByText('Quantity must not be above 100')).toBeInTheDocument();
    });

    expect(screen.getByRole('button', { name: 'Submit' })).toBeDisabled();
  });

  it('does not submit when Enter is pressed with an invalid quantity', async () => {
    mockListRequest();

    const postScope = nockInstance
      .post(upstreamSubscriptionsPath)
      .reply(200, taskSuccessResponse);

    renderUpstreamSubscriptionsPage();
    await waitForSubscriptionsTable();

    const quantityInput = screen.getAllByLabelText('Number to Allocate')[0];
    await userEvent.type(quantityInput, '101{Enter}');

    await patientlyWaitFor(() => {
      expect(screen.getByText('Quantity must not be above 100')).toBeInTheDocument();
    });

    expect(postScope.isDone()).toBe(false);
  });

  it('shows table error state when list request fails', async () => {
    nockInstance
      .get(upstreamSubscriptionsPath)
      .query(true)
      .reply(422, { error: { message: 'Unable to load upstream subscriptions' } })
      .persist();

    renderUpstreamSubscriptionsPage();

    await patientlyWaitFor(() => {
      expect(screen.getByText('Unable to load upstream subscriptions')).toBeInTheDocument();
    });

    expect(screen.queryByRole('heading', { level: 5, name: 'There are no Manifests to display' })).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: 'Submit' })).not.toBeInTheDocument();
  });

  it('does not show the custom empty state when the API response has failed without a message', () => {
    jest.spyOn(APIActions, 'get').mockReturnValue({ type: 'MOCK_NO_API' });

    renderWithStore(
      <Router history={createMemoryHistory({ initialEntries: ['/'] })}>
        <UpstreamSubscriptionsPage />
      </Router>,
      {
        API: {
          [UPSTREAM_SUBSCRIPTIONS_KEY]: {
            response: { results: [] },
            status: STATUS.ERROR,
          },
        },
      },
    );

    expect(screen.queryByRole('heading', { level: 5, name: 'There are no Manifests to display' })).not.toBeInTheDocument();
    expect(screen.queryByText('Import a Manifest to Begin')).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: 'Submit' })).not.toBeInTheDocument();
  });

  it('shows the custom empty state when there are no subscriptions', async () => {
    mockListRequest(emptyListResponse);

    renderUpstreamSubscriptionsPage();

    await patientlyWaitFor(() => {
      expect(screen.getByRole('heading', { level: 5, name: 'There are no Manifests to display' })).toBeInTheDocument();
      expect(screen.getByText('Import a Manifest to Begin')).toBeInTheDocument();
    });

    expect(screen.queryByRole('button', { name: 'Submit' })).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: 'Cancel' })).not.toBeInTheDocument();
  });

  it('navigates to subscriptions when cancel is clicked', async () => {
    mockListRequest();
    const history = createMemoryHistory({ initialEntries: ['/subscriptions/add'] });

    renderUpstreamSubscriptionsPage(history);
    await waitForSubscriptionsTable();

    await userEvent.click(screen.getByRole('button', { name: 'Cancel' }));

    expect(history.location.pathname).toBe('/subscriptions');
  });

  it('submits selected quantities and shows success toast', async () => {
    mockListRequest();
    const history = createMemoryHistory({ initialEntries: ['/subscriptions/add'] });

    const postScope = nockInstance
      .post(upstreamSubscriptionsPath, {
        pools: [{ id: requestSuccessResponse.results[0].id, quantity: 5 }],
      })
      .reply(200, taskSuccessResponse);

    const { store } = renderUpstreamSubscriptionsPage(history);
    await waitForSubscriptionsTable();

    await userEvent.type(screen.getAllByLabelText('Number to Allocate')[0], '5');
    await userEvent.click(screen.getByRole('button', { name: 'Submit' }));

    await patientlyWaitFor(() => {
      const toasts = Object.values(store.getState().toasts);
      expect(toasts.some(({ type }) => type === 'success')).toBe(true);
      expect(history.location.pathname).toBe('/subscriptions');
    });

    assertNockRequest(postScope);
  });

  it('submits quantities for multiple selected rows', async () => {
    mockListRequest();
    const history = createMemoryHistory({ initialEntries: ['/subscriptions/add'] });
    let postedBody;

    const postScope = nockInstance
      .post(upstreamSubscriptionsPath, (body) => {
        postedBody = body;
        return true;
      })
      .reply(200, taskSuccessResponse);

    renderUpstreamSubscriptionsPage(history);
    await waitForSubscriptionsTable();

    const quantityInputs = screen.getAllByLabelText('Number to Allocate');
    await userEvent.type(quantityInputs[0], '5');
    await userEvent.type(screen.getAllByLabelText('Number to Allocate')[1], '8');

    await patientlyWaitFor(() => {
      expect(screen.getAllByLabelText('Number to Allocate')[1]).toHaveValue('8');
    });

    await userEvent.click(screen.getByRole('button', { name: 'Submit' }));

    await patientlyWaitFor(() => {
      expect(postedBody).toEqual({
        pools: [
          { id: requestSuccessResponse.results[0].id, quantity: 5 },
          { id: requestSuccessResponse.results[1].id, quantity: 8 },
        ],
      });
      expect(history.location.pathname).toBe('/subscriptions');
    });

    assertNockRequest(postScope);
  });

  it('shows saving state while save is in progress', async () => {
    mockListRequest();

    const postScope = nockInstance
      .post(upstreamSubscriptionsPath, {
        pools: [{ id: requestSuccessResponse.results[0].id, quantity: 5 }],
      })
      .delay(500)
      .reply(200, taskSuccessResponse);

    renderUpstreamSubscriptionsPage();
    await waitForSubscriptionsTable();

    await userEvent.type(screen.getAllByLabelText('Number to Allocate')[0], '5');
    await userEvent.click(screen.getByRole('button', { name: 'Submit' }));

    expect(screen.getByRole('heading', { level: 5, name: 'Saving...' })).toBeInTheDocument();
    expect(screen.queryByText(requestSuccessResponse.results[0].product_name)).not.toBeInTheDocument();

    await patientlyWaitFor(() => {
      expect(postScope.isDone()).toBe(true);
    });
  });

  it('shows error toast when save fails', async () => {
    mockListRequest();
    const history = createMemoryHistory({ initialEntries: ['/subscriptions/add'] });

    const postScope = nockInstance
      .post(upstreamSubscriptionsPath)
      .reply(422, { error: { message: 'Unable to save subscriptions' } });

    const { store } = renderUpstreamSubscriptionsPage(history);
    await waitForSubscriptionsTable();

    await userEvent.type(screen.getAllByLabelText('Number to Allocate')[0], '5');
    await userEvent.click(screen.getByRole('button', { name: 'Submit' }));

    await patientlyWaitFor(() => {
      const toasts = Object.values(store.getState().toasts);
      expect(toasts.some(({ type }) => type === 'danger')).toBe(true);
    });

    expect(history.location.pathname).toBe('/subscriptions/add');
    assertNockRequest(postScope);
  });
});
