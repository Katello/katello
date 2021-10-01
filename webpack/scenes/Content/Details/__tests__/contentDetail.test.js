import React from 'react';
import { Route } from 'react-router-dom';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest, mockAutocomplete, mockSetting } from '../../../../test-utils/nockWrapper';
import api from '../../../../services/api';
import { CONTENT_ID_KEY } from '../../ContentConstants';
import ContentDetails from '../ContentDetails';
import ContentRepositories from '../ContentRepositories';

const pythonPackageDetailsResponse = require('./pythonPackageDetails.fixtures.json');
const pythonPackageRepositoryDetailsResponse = require('./pythonPackageRepositoryDetails.fixtures.json');

const pythonPackageDetailsPath = api.getApiUrl('/python_packages/1491');
const pythonPackageRepositoryDetailsPath = api.getApiUrl('/repositories');

const withContentRoute = component => <Route path="/content/:content_type([a-z_]+)/:id([0-9]+)">{component}</Route>;

let searchDelayScope;
let autoSearchScope;

test('Can call API for Python package details and show details tab on page load', async (done) => {
  const renderOptions = {
    apiNamespace: CONTENT_ID_KEY,
    routerParams: {
      initialEntries: [{ pathname: '/content/python_packages/1491', hash: '#/details' }],
      initialIndex: 1,
    },
  };

  const { name, version } = pythonPackageDetailsResponse;
  const pythonPackagesScope = nockInstance
    .get(pythonPackageDetailsPath)
    .query(true)
    .reply(200, pythonPackageDetailsResponse);

  const { queryByText, getAllByText, getByLabelText } =
    renderWithRedux(withContentRoute(<ContentDetails />), renderOptions);

  expect(queryByText(name)).toBeNull();
  await patientlyWaitFor(() => {
    expect(getAllByText(name)[0]).toBeInTheDocument();
    expect(getAllByText(version)[0]).toBeInTheDocument();
    expect(getByLabelText('content_breadcrumb')).toBeInTheDocument();
    expect(getByLabelText('content_breadcrumb_content')).toHaveTextContent(name);
  });

  assertNockRequest(pythonPackagesScope, done);
});

test('Can call API for Python package repository details and show repositories tab', async (done) => {
  const autocompleteUrl = '/repositories/auto_complete_search';
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 500);
  autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing', true);

  const results = pythonPackageRepositoryDetailsResponse.results[0];
  const repoName = results.name;
  const productName = results.product.name;
  const lastSyncWords = `${results.last_sync_words} ago`;
  const contentCountWords = '1489 Python packages';

  const pythonPackageRepositoryDetailsScope = nockInstance
    .get(pythonPackageRepositoryDetailsPath)
    .query(true)
    .reply(200, pythonPackageRepositoryDetailsResponse);

  const { queryByText, getAllByText } =
    renderWithRedux(<ContentRepositories tabKey="repositories" id={1491} contentType="python_packages" />);

  expect(queryByText(repoName)).toBeNull();
  await patientlyWaitFor(() => {
    expect(getAllByText(repoName)[0]).toBeInTheDocument();
    expect(getAllByText(productName)[0]).toBeInTheDocument();
    expect(getAllByText(lastSyncWords)[0]).toBeInTheDocument();
    expect(getAllByText(contentCountWords)[0]).toBeInTheDocument();
  });

  assertNockRequest(autoSearchScope);
  assertNockRequest(searchDelayScope);
  assertNockRequest(autocompleteScope);
  assertNockRequest(pythonPackageRepositoryDetailsScope, done);
});
