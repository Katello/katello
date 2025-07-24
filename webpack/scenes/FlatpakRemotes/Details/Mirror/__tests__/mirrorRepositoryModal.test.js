import React from 'react';
import { Route } from 'react-router-dom';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import { fireEvent } from '@testing-library/react';
import { nockInstance, assertNockRequest } from '../../../../../test-utils/nockWrapper';
import api from '../../../../../services/api';
import FlatpakRemoteDetails from '../../FlatpakRemoteDetails';
import FLATPAK_REMOTES_KEY from '../../../FlatpakRemotesConstants';
import frDetailData from '../../__tests__/flatpakRemoteDetails.fixtures.json';

jest.mock('react-intl', () => ({ addLocaleData: () => { }, FormattedDate: () => 'mocked' }));

const withFRRoute = component => <Route path="/flatpak_remotes/:id([0-9]+)">{component}</Route>;

const renderOptions = {
  apiNamespace: `${FLATPAK_REMOTES_KEY}_1`,
  routerParams: {
    initialEntries: [{ pathname: '/flatpak_remotes/1' }],
    initialIndex: 1,
  },
};

const frDetailsPath = api.getApiUrl('/flatpak_remotes/1');
const repoApiUrl = api.getApiUrl('/flatpak_remotes/1/flatpak_remote_repositories');

test('Can open mirror repository modal', async () => {
  const frDetailsScope = nockInstance
    .get(frDetailsPath)
    .query(true)
    .reply(200, frDetailData);

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

  const productAutocompleteScope = nockInstance
    .get(api.getApiUrl('/products/auto_complete_name'))
    .query(true)
    .reply(200, ['Product1', 'Product2', 'Product3']);

  const flatpakRepoAutocompleteScope = nockInstance
    .get(api.getApiUrl('/flatpak_remote_repositories/auto_complete_search'))
    .query(true)
    .reply(200, []);

  const { getByText, getByRole } = renderWithRedux(
    withFRRoute(<FlatpakRemoteDetails />),
    renderOptions,
  );

  await patientlyWaitFor(() => {
    expect(getByText(frDetailData.repositories[0].name)).toBeInTheDocument();
  });

  getByText('Mirror', {
    selector: '[data-ouia-component-id="mirror-button-1"]',
  }).click();

  await patientlyWaitFor(() => {
    expect(getByRole('textbox')).toBeInTheDocument();
    expect(getByText('Mirror', {
      selector: '[data-ouia-component-id="confirm-mirror-btn"]',
    })).toBeInTheDocument();
  });

  assertNockRequest(frDetailsScope);
  assertNockRequest(scopeRepos);
  assertNockRequest(productAutocompleteScope);
  assertNockRequest(flatpakRepoAutocompleteScope);
});

test('Can successfully mirror a repository', async () => {
  const selectedRepo = frDetailData.repositories[0];
  const productName = 'Product1';

  const frDetailsScope = nockInstance
    .get(frDetailsPath)
    .query(true)
    .reply(200, frDetailData);

  const scopeRepos = nockInstance
    .get(repoApiUrl)
    .query(true)
    .times(3)
    .reply(200, {
      results: frDetailData.repositories,
      subtotal: frDetailData.repositories.length,
      page: 1,
      per_page: 20,
    });

  const productAutocompleteScope = nockInstance
    .get(api.getApiUrl('/products/auto_complete_name'))
    .query(true)
    .reply(200, ['Product1', 'Product2', 'Product3']);

  const flatpakRepoAutocompleteScope = nockInstance
    .get(api.getApiUrl('/flatpak_remote_repositories/auto_complete_search'))
    .query(true)
    .reply(200, []);

  const mirrorScope = nockInstance
    .post(api.getApiUrl(`/flatpak_remote_repositories/${selectedRepo.id}/mirror`), {
      product_name: productName,
      organization_id: 1,
    })
    .reply(200, { task_id: 'mirror-task-123' });

  const { getByText, getByRole } = renderWithRedux(
    withFRRoute(<FlatpakRemoteDetails />),
    renderOptions,
  );

  await patientlyWaitFor(() => {
    expect(getByText(selectedRepo.name)).toBeInTheDocument();
  });

  getByText('Mirror', {
    selector: '[data-ouia-component-id="mirror-button-1"]',
  }).click();

  await patientlyWaitFor(() => {
    expect(getByText('Mirror Repository')).toBeInTheDocument();
  });

  const productInput = getByRole('textbox');
  fireEvent.change(productInput, { target: { value: productName } });

  await patientlyWaitFor(() => {
    expect(getByText('Mirror', {
      selector: '[data-ouia-component-id="confirm-mirror-btn"]',
    })).toBeInTheDocument();
  });

  getByText('Mirror', {
    selector: '[data-ouia-component-id="confirm-mirror-btn"]',
  }).click();

  await patientlyWaitFor(() => {
    assertNockRequest(mirrorScope);
  });

  assertNockRequest(frDetailsScope);
  assertNockRequest(scopeRepos);
  assertNockRequest(productAutocompleteScope);
  assertNockRequest(flatpakRepoAutocompleteScope);
});
