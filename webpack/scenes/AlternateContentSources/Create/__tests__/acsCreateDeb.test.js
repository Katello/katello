import React from 'react';
import { Route } from 'react-router-dom';
import { act, fireEvent, patientlyWaitFor, renderWithRedux } from 'react-testing-lib-wrapper';
import api from '../../../../services/api';
import { assertNockRequest, mockAutocomplete, nockInstance } from '../../../../test-utils/nockWrapper';
import ACSTable from '../../MainTable/ACSTable';
import contentCredentialResult from './contentCredentials.fixtures';
import smartProxyResult from './smartProxy.fixtures';
import productsResult from './products.fixtures.json';

const withACSRoute = component => <Route path="/alternate_content_sources/">{component}</Route>;
const ACSIndexPath = api.getApiUrl('/alternate_content_sources');
const contentCredentialPath = api.getApiUrl('/content_credentials');
const smartProxyPath = api.getApiUrl('/capsules');
const productsPath = api.getApiUrl('/products');
const autocompleteUrl = '/alternate_content_sources/auto_complete_search';

const renderOptions = {
  routerParams: {
    initialEntries: [{ pathname: '/alternate_content_sources/' }],
  },
};

const noResults = {
  total: 0,
  subtotal: 0,
  page: 1,
  per_page: 20,
  results: [],
  can_create: true,
};

const contentTypeValues = (select) => Array.from(select.options).map(option => option.value);

test('Satellite ACS wizard offers only yum and file', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const productScope = nockInstance
    .get(productsPath)
    .query(true)
    .reply(200, productsResult);

  const listScope = nockInstance
    .get(ACSIndexPath)
    .query(true)
    .reply(200, noResults);

  const contentCredentialScope = nockInstance
    .get(contentCredentialPath)
    .query(true)
    .reply(200, contentCredentialResult);

  const smartProxyScope = nockInstance
    .get(smartProxyPath)
    .query(true)
    .reply(200, smartProxyResult);

  const {
    getByText,
    getByLabelText,
    queryByText,
  } = renderWithRedux(withACSRoute(<ACSTable />), renderOptions);

  await patientlyWaitFor(() =>
    expect(queryByText("You currently don't have any alternate content sources.")).toBeInTheDocument());
  fireEvent.click(getByText('Add source'));

  await patientlyWaitFor(() =>
    expect(getByText('Add an alternate content source')).toBeInTheDocument());

  const contentTypeSelect = getByLabelText('FormSelect Input');

  fireEvent.click(getByText('Custom'));
  expect(contentTypeValues(contentTypeSelect)).toEqual(['yum', 'file']);

  fireEvent.click(getByText('Simplified'));
  expect(contentTypeValues(contentTypeSelect)).toEqual(['yum', 'file']);

  fireEvent.click(getByText('RHUI'));
  expect(contentTypeValues(contentTypeSelect)).toEqual(['yum']);

  assertNockRequest(autocompleteScope);
  assertNockRequest(listScope);
  assertNockRequest(contentCredentialScope);
  assertNockRequest(smartProxyScope);
  assertNockRequest(productScope);
  act(done);
});
