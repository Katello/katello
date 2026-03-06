import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import ContentCredentialsPage from '../ContentCredentialsPage';
import api from '../../../services/api';
import { nockInstance, assertNockRequest } from '../../../test-utils/nockWrapper';
import contentCredentialsData from './contentCredentialsList.fixtures.json';

const contentCredentialsPath = api.getApiUrl('/content_credentials');
const autocompleteUrl = '/katello/api/v2/content_credentials/auto_complete_search';
const renderOptions = { apiNamespace: 'CONTENT_CREDENTIALS' };
const autocompleteQuery = {
  search: '',
  organization_id: '1',
};

let firstCredential;
let secondCredential;
beforeEach(() => {
  const { results } = contentCredentialsData;
  [firstCredential, secondCredential] = results;
});

test('Can call API for Content Credentials and show on screen on page load', async () => {
  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(autocompleteQuery)
    .reply(200, []);

  const scope = nockInstance
    .get(contentCredentialsPath)
    .query(true)
    .times(2)
    .reply(200, contentCredentialsData);

  const { queryByText } = renderWithRedux(<ContentCredentialsPage />, renderOptions);

  expect(queryByText(firstCredential.name)).toBeNull();

  await patientlyWaitFor(() => {
    expect(queryByText(firstCredential.name)).toBeInTheDocument();
    expect(queryByText(secondCredential.name)).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
});

test('Displays empty state when no content credentials exist', async () => {
  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(autocompleteQuery)
    .reply(200, []);

  const emptyScope = nockInstance
    .get(contentCredentialsPath)
    .query(true)
    .times(2)
    .reply(200, {
      total: 0,
      subtotal: 0,
      page: 1,
      per_page: 20,
      results: [],
    });

  const { queryByText } = renderWithRedux(<ContentCredentialsPage />, renderOptions);

  await patientlyWaitFor(() => {
    expect(queryByText(/no results/i)).toBeInTheDocument();
  });

  assertNockRequest(emptyScope);
  assertNockRequest(autocompleteScope);
});

test('Displays correct content type labels', async () => {
  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(autocompleteQuery)
    .reply(200, []);

  const scope = nockInstance
    .get(contentCredentialsPath)
    .query(true)
    .times(2)
    .reply(200, contentCredentialsData);

  const { queryByText, queryAllByText } = renderWithRedux(
    <ContentCredentialsPage />,
    renderOptions,
  );

  await patientlyWaitFor(() => {
    // 'cert' type should display as 'Certificate'
    expect(queryAllByText('Certificate').length).toBeGreaterThanOrEqual(1);
    // 'gpg_key' type should display as 'GPG Key'
    expect(queryByText('GPG Key')).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
});

test('Displays organization name for each credential', async () => {
  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(autocompleteQuery)
    .reply(200, []);

  const scope = nockInstance
    .get(contentCredentialsPath)
    .query(true)
    .times(2)
    .reply(200, contentCredentialsData);

  const { queryAllByText } = renderWithRedux(
    <ContentCredentialsPage />,
    renderOptions,
  );

  await patientlyWaitFor(() => {
    expect(queryAllByText('ISS').length).toBeGreaterThanOrEqual(1);
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
});

test('Displays correct products count', async () => {
  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(autocompleteQuery)
    .reply(200, []);

  const scope = nockInstance
    .get(contentCredentialsPath)
    .query(true)
    .times(2)
    .reply(200, contentCredentialsData);

  const { queryByText } = renderWithRedux(
    <ContentCredentialsPage />,
    renderOptions,
  );

  await patientlyWaitFor(() => {
    // DevelServerCA has 1 ssl_ca_product
    // MyGPGKey has 2 gpg_key_products
    expect(queryByText(firstCredential.name)).toBeInTheDocument();
    expect(queryByText(secondCredential.name)).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
});

test('Displays Content Credentials header', async () => {
  const autocompleteScope = nockInstance
    .get(autocompleteUrl)
    .query(autocompleteQuery)
    .reply(200, []);

  const scope = nockInstance
    .get(contentCredentialsPath)
    .query(true)
    .times(2)
    .reply(200, contentCredentialsData);

  const { queryByText } = renderWithRedux(
    <ContentCredentialsPage />,
    renderOptions,
  );

  await patientlyWaitFor(() => {
    expect(queryByText('Content Credentials')).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
});
