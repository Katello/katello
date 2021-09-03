import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import nock, { nockInstance, assertNockRequest, mockAutocomplete, mockSetting } from '../../../test-utils/nockWrapper';
import api from '../../../services/api';
import ContentPage from '../ContentPage';

const contentTypesResponse = require('./contentTypes.fixtures.json');
const pythonPackagesResponse = require('./pythonPackages.fixtures.json');

const contentTypesPath = api.getApiUrl('/repositories/content_types');
const pythonPackagesPath = api.getApiUrl('/python_packages');

let searchDelayScope;
let autoSearchScope;

beforeEach(() => {
  searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 500);
  autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing', true);
});

afterEach(() => {
  nock.cleanAll();
  assertNockRequest(autoSearchScope);
  assertNockRequest(searchDelayScope);
});

test('Can call API for Python Packages and show table on page load', async (done) => {
  const autocompleteUrl = '/python_packages/auto_complete_search';
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const { results } = pythonPackagesResponse;
  const [firstPackage] = results;

  const pythonPackagesScope = nockInstance
    .get(pythonPackagesPath)
    .query(true)
    .reply(200, pythonPackagesResponse);
  const contentTypesScope = nockInstance
    .get(contentTypesPath)
    .query(true)
    .reply(200, contentTypesResponse);

  const { queryByText, getAllByText } =
    renderWithRedux(<ContentPage />);

  expect(queryByText(firstPackage.name)).toBeNull();
  await patientlyWaitFor(() => {
    expect(getAllByText(firstPackage.name)[0]).toBeInTheDocument();
    expect(getAllByText(firstPackage.version)[0]).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(contentTypesScope);
  assertNockRequest(pythonPackagesScope, done);
});
