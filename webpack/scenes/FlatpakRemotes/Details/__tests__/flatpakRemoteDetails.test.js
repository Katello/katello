import React from 'react';
import { Route } from 'react-router-dom';
import { renderWithRedux, patientlyWaitFor, screen } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest } from '../../../../test-utils/nockWrapper';
import api from '../../../../services/api';
import FlatpakRemoteDetails from '../FlatpakRemoteDetails';
import FLATPAK_REMOTES_KEY from '../../FlatpakRemotesConstants';
import frDetailData from './flatpakRemoteDetails.fixtures.json';

jest.mock('react-intl', () => ({ addLocaleData: () => { }, FormattedDate: () => 'mocked' }));

const withFRRoute = component => <Route path="/flatpak_remotes/:id([0-9]+)">{component}</Route>;

const renderOptions = {
  apiNamespace: `${FLATPAK_REMOTES_KEY}_1`,
  routerParams: {
    initialEntries: [{ pathname: '/flatpak_remotes/1' }],
    initialIndex: 1,
  },
};

const inProgressScanFrDetailData = {
  ...frDetailData,
  last_scan: {
    ...frDetailData.last_scan,
    progress: 0.2,
  },
};

const frDetailsPath = api.getApiUrl('/flatpak_remotes/1');
const repoApiUrl = api.getApiUrl('/flatpak_remotes/1/flatpak_remote_repositories');
const autocompleteApiUrl = api.getApiUrl('/flatpak_remote_repositories/auto_complete_search');

const mockAutocomplete = () =>
  nockInstance
    .get(autocompleteApiUrl)
    .query({ search: '' })
    .reply(200, []);
test('Can call API and display details on load', async () => {
  const scopeDetails = nockInstance
    .get(frDetailsPath)
    .query(true)
    .reply(200, frDetailData)
    .persist();

  const scopeRepos = nockInstance
    .get(repoApiUrl)
    .query(true)
    .times(2)
    .reply(200, {
      results: frDetailData.repositories,
      subtotal: frDetailData.repositories.length,
      page: 1,
      per_page: 20,
    });

  const scopeAutocomplete = mockAutocomplete();

  const { getByText, unmount } = renderWithRedux(
    withFRRoute(<FlatpakRemoteDetails />),
    renderOptions,
  );

  await patientlyWaitFor(() => {
    expect(getByText(frDetailData.url)).toBeInTheDocument();
  });

  const scanButton = screen.getByLabelText('scan_flatpak_remote');
  expect(scanButton).toHaveAttribute('aria-disabled', 'false');

  await patientlyWaitFor(() => {
    expect(getByText(`${frDetailData.last_scan_words} ago`)).toBeInTheDocument();
  });

  unmount();
  scopeDetails.persist(false);

  assertNockRequest(scopeDetails);
  assertNockRequest(scopeRepos);
  assertNockRequest(scopeAutocomplete);
});

test('Can call API and display in progress scan state', async () => {
  const scopeDetails = nockInstance
    .get(frDetailsPath)
    .query(true)
    .reply(200, inProgressScanFrDetailData)
    .persist();

  const scopeRepos = nockInstance
    .get(repoApiUrl)
    .query(true)
    .times(2)
    .reply(200, {
      results: frDetailData.repositories,
      subtotal: frDetailData.repositories.length,
      page: 1,
      per_page: 20,
    });

  const scopeAutocomplete = mockAutocomplete();

  const { getByText, queryByText, unmount } = renderWithRedux(
    withFRRoute(<FlatpakRemoteDetails />),
    renderOptions,
  );

  await patientlyWaitFor(() => {
    expect(getByText(frDetailData.url)).toBeInTheDocument();
  });

  await patientlyWaitFor(() => {
    expect(getByText('In progress')).toBeInTheDocument();
  });

  expect(screen.getByRole('progressbar', { name: /spinner/i })).toBeInTheDocument();
  expect(queryByText(`${frDetailData.last_scan_words} ago`)).not.toBeInTheDocument();

  const scanButton = screen.getByLabelText('scan_flatpak_remote');
  expect(scanButton).toHaveAttribute('aria-disabled', 'true');
  expect(scanButton).toHaveClass('pf-m-in-progress');

  unmount();
  scopeDetails.persist(false);

  assertNockRequest(scopeRepos);
  assertNockRequest(scopeAutocomplete);
});

test('Displays empty state when repository list is empty', async () => {
  const scopeDetails = nockInstance
    .get(frDetailsPath)
    .query(true)
    .reply(200, frDetailData)
    .persist();

  const scopeRepos = nockInstance
    .get(repoApiUrl)
    .query(true)
    .reply(200, {
      results: [],
      subtotal: 0,
      page: 1,
      per_page: 20,
    })
    .persist();

  const scopeAutocomplete = nockInstance
    .get(autocompleteApiUrl)
    .query(true)
    .reply(200, [])
    .persist();

  const { findByText, queryByText, unmount } = renderWithRedux(
    withFRRoute(<FlatpakRemoteDetails />),
    renderOptions,
  );

  await patientlyWaitFor(() => {
    expect(queryByText(/loading/i)).not.toBeInTheDocument();
  });

  expect(await findByText(/no results/i)).toBeInTheDocument();

  unmount();
  scopeDetails.persist(false);
  scopeRepos.persist(false);
  scopeAutocomplete.persist(false);
});

