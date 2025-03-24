import React from 'react';
import * as reactRedux from 'react-redux';
import { Route } from 'react-router-dom';
import { act, fireEvent, patientlyWaitFor, renderWithRedux } from 'react-testing-lib-wrapper';
import api, { foremanApi } from '../../../../services/api';
import { assertNockRequest, mockAutocomplete, nockInstance } from '../../../../test-utils/nockWrapper';
import ACSTable from '../../MainTable/ACSTable';
import contentCredentialResult from './contentCredentials.fixtures';
import smartProxyResult from './smartProxy.fixtures';
import productsResult from './products.fixtures.json';

const withACSRoute = component => <Route path="/alternate_content_sources/">{component}</Route>;
const ACSIndexPath = api.getApiUrl('/alternate_content_sources');
const ACSCreatePath = api.getApiUrl('/alternate_content_sources');
const contentCredentialPath = api.getApiUrl('/content_credentials');
const smartProxyPath = foremanApi.getApiUrl('/smart_proxies');
const productsPath = api.getApiUrl('/products');
const autocompleteUrl = '/alternate_content_sources/auto_complete_search';

const createCustomACSDetails = {
  upstream_username: 'username',
  upstream_password: 'password',
  name: 'acs_test',
  description: '',
  base_url: 'https://test_url.com/',
  subpaths: ['test/repo1/', 'test/repo2/'],
  smart_proxy_names: ['centos7-katello-devel-stable.example.com'],
  content_type: 'yum',
  alternate_content_source_type: 'custom',
  verify_ssl: false,
  use_http_proxies: false,
  ssl_ca_cert_id: '',
};

const createSimplifiedACSDetails = {
  name: 'acs_simplified_test',
  description: '',
  smart_proxy_names: ['centos7-katello-devel-stable.example.com'],
  product_ids: [340, 19, 341],
  content_type: 'yum',
  alternate_content_source_type: 'simplified',
  use_http_proxies: false,
};

const createRHUIACSDetails = {
  name: 'acs_rhui_test',
  description: '',
  base_url: 'https://test_url.com/pulp/content',
  subpaths: ['test/repo1/', 'test/repo2/'],
  smart_proxy_names: ['centos7-katello-devel-stable.example.com'],
  content_type: 'yum',
  alternate_content_source_type: 'rhui',
  verify_ssl: false,
  use_http_proxies: false,
  ssl_ca_cert_id: '',
};

const noResults = {
  total: 0,
  subtotal: 0,
  page: 1,
  per_page: 20,
  results: [],
  can_create: true,
};

const renderOptions = {
  routerParams: {
    initialEntries: [{ pathname: '/alternate_content_sources/' }],
  },
};

test('Can show add ACS button if can_create is true', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(ACSIndexPath)
    .query(true)
    .reply(200, noResults);

  const { queryByText } = renderWithRedux(<ACSTable />);

  expect(queryByText("You currently don't have any alternate content sources.")).toBeNull();
  await patientlyWaitFor(() => expect(queryByText("You currently don't have any alternate content sources.")).toBeInTheDocument());
  expect(queryByText('Add source')).toBeInTheDocument();
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  act(done);
});

test('Can hide add ACS button if can_create is false', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  noResults.can_create = false;
  const scope = nockInstance
    .get(ACSIndexPath)
    .query(true)
    .reply(200, noResults);

  const { queryByText } = renderWithRedux(<ACSTable />);

  expect(queryByText("You currently don't have any alternate content sources.")).toBeNull();
  await patientlyWaitFor(() => expect(queryByText("You currently don't have any alternate content sources.")).toBeInTheDocument());
  expect(queryByText('Add source')).not.toBeInTheDocument();
  noResults.can_create = true;
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  act(done);
});

test('Can display create wizard and create custom ACS', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(ACSIndexPath)
    .query(true)
    .times(2)
    .reply(200, noResults);

  const contentCredentialScope = nockInstance
    .get(contentCredentialPath)
    .query(true)
    .reply(200, contentCredentialResult);

  const productScope = nockInstance
    .get(productsPath)
    .query(true)
    .reply(200, productsResult);

  const smartProxyScope = nockInstance
    .get(smartProxyPath)
    .query(true)
    .reply(200, smartProxyResult);

  const createScope = nockInstance
    .post(ACSCreatePath, createCustomACSDetails)
    .reply(201, { id: 22 });

  const {
    getByLabelText, getByText, getAllByRole, queryByText,
  } = renderWithRedux(withACSRoute(<ACSTable />), renderOptions);

  expect(queryByText("You currently don't have any alternate content sources.")).toBeNull();
  await patientlyWaitFor(() => expect(queryByText("You currently don't have any alternate content sources.")).toBeInTheDocument());
  expect(queryByText('Add source')).toBeInTheDocument();
  fireEvent.click(getByText('Add source'));

  // First step: Select source
  await patientlyWaitFor(() => {
    expect(getByText('Add an alternate content source')).toBeInTheDocument();
    expect(queryByText('Alternate content sources define new locations to download content from at repository or smart proxy sync time.')).toBeInTheDocument();
  });

  // Check that next is disabled until type is selected
  expect(getByText('Next')).toHaveAttribute('disabled');
  fireEvent.click(getByText('Custom'));
  expect(getByText('Next')).not.toHaveAttribute('disabled');
  // Go to next step: Name source
  fireEvent.click(getByText('Next'));

  await patientlyWaitFor(() => {
    expect(getByText('Enter a name for your source.')).toBeInTheDocument();
  });
  // Check that next is disabled until name is entered
  expect(getByText('Next')).toHaveAttribute('disabled');
  // Enter Name
  fireEvent.change(getByLabelText('acs_name_field'), { target: { value: 'acs_test' } });
  expect(getByText('Next')).not.toHaveAttribute('disabled');
  // Mock smart proxy selector to go to next page
  const useSmartProxySelectorMock = jest.spyOn(reactRedux, 'useSelector');
  useSmartProxySelectorMock.mockReturnValue(smartProxyResult);
  fireEvent.click(getByText('Next'));
  await patientlyWaitFor(() => {
    expect(getByText('centos7-katello-devel-stable.example.com')).toBeInTheDocument();
  });

  // Check that next is disabled until proxies are selected
  expect(getByText('Next')).toHaveAttribute('disabled');
  fireEvent.click(getByLabelText('Add all'));
  useSmartProxySelectorMock.mockRestore();
  // Go to URL and subpath step
  fireEvent.click(getByText('Next'));

  // Check that next is disabled until URL is entered
  expect(getByText('Next')).toHaveAttribute('disabled');

  // Test url/subpath validations
  fireEvent.change(getByLabelText('acs_base_url_field'), { target: { value: 'ivalidUrlWithoutProtocol' } });
  expect(getByText('http://, https:// or file://')).toBeInTheDocument();
  fireEvent.change(getByLabelText('acs_subpath_field'), { target: { value: 'invalid/noTrailingSlash' } });
  expect(getByText('Comma-separated list of subpaths. All subpaths must have a slash at the end and none at the front.')).toBeInTheDocument();
  // Test that next is still diabled with invalid values
  expect(getByText('Next')).toHaveAttribute('disabled');

  fireEvent.change(getByLabelText('acs_base_url_field'), { target: { value: 'https://test_url.com/' } });
  expect(getByLabelText('acs_base_url_field')).toHaveAttribute('value', 'https://test_url.com/');
  fireEvent.change(getByLabelText('acs_subpath_field'), { target: { value: 'test/repo1/,test/repo2/' } });

  // Mock content credential data
  const useContentCredentialSelectorMock = jest.spyOn(reactRedux, 'useSelector');
  useContentCredentialSelectorMock.mockReturnValue(contentCredentialResult.results);
  fireEvent.click(getByText('Next'));
  const manualAuthRadio = getAllByRole('radio', { name: 'Manual authentication' })[0];
  fireEvent.click(manualAuthRadio);
  await patientlyWaitFor(() => {
    expect(getByText('Username')).toBeInTheDocument();
    expect(getByText('Password')).toBeInTheDocument();
  });
  fireEvent.change(getByLabelText('acs_username_field'), { target: { value: 'username' } });
  fireEvent.change(getByLabelText('acs_password_field'), { target: { value: 'password' } });
  useContentCredentialSelectorMock.mockRestore();
  fireEvent.click(getByText('Next'));
  const addAcsButton = getAllByRole('button', { name: 'Add' })[0];
  fireEvent.click(addAcsButton);

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  assertNockRequest(contentCredentialScope);
  assertNockRequest(productScope);
  assertNockRequest(smartProxyScope);
  assertNockRequest(createScope);
  done();
  act(done);
});

test('Can display create wizard and create RHUI ACS', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(ACSIndexPath)
    .query(true)
    .times(2)
    .reply(200, noResults);

  const contentCredentialScope = nockInstance
    .get(contentCredentialPath)
    .query(true)
    .reply(200, contentCredentialResult);

  const productScope = nockInstance
    .get(productsPath)
    .query(true)
    .reply(200, productsResult);

  const smartProxyScope = nockInstance
    .get(smartProxyPath)
    .query(true)
    .reply(200, smartProxyResult);

  const createScope = nockInstance
    .post(ACSCreatePath, createRHUIACSDetails)
    .reply(201, { id: 22 });

  const {
    getByLabelText, getByText, getAllByRole, queryByText,
  } = renderWithRedux(withACSRoute(<ACSTable />), renderOptions);

  expect(queryByText("You currently don't have any alternate content sources.")).toBeNull();
  await patientlyWaitFor(() => expect(queryByText("You currently don't have any alternate content sources.")).toBeInTheDocument());
  expect(queryByText('Add source')).toBeInTheDocument();
  fireEvent.click(getByText('Add source'));

  // First step: Select source
  await patientlyWaitFor(() => {
    expect(getByText('Add an alternate content source')).toBeInTheDocument();
    expect(getByText('Alternate content sources define new locations to download content from at repository or smart proxy sync time.')).toBeInTheDocument();
  });

  // Choose ACS type, content_type defaults to yum
  fireEvent.click(getByText('RHUI'));

  // Go to next step: Name source
  fireEvent.click(getByText('Next'));

  await patientlyWaitFor(() => {
    expect(getByText('Enter a name for your source.')).toBeInTheDocument();
  });
  // Enter Name
  fireEvent.change(getByLabelText('acs_name_field'), { target: { value: 'acs_rhui_test' } });

  // Mock smart proxy selector to go to next page
  const useSmartProxySelectorMock = jest.spyOn(reactRedux, 'useSelector');
  useSmartProxySelectorMock.mockReturnValue(smartProxyResult);
  fireEvent.click(getByText('Next'));
  await patientlyWaitFor(() => {
    expect(getByText('centos7-katello-devel-stable.example.com')).toBeInTheDocument();
  });
  fireEvent.click(getByLabelText('Add all'));
  useSmartProxySelectorMock.mockRestore();
  // Go to URL and subpath step
  fireEvent.click(getByText('Next'));

  fireEvent.change(getByLabelText('acs_base_url_field'), { target: { value: 'https://test_url.com/pulp/content' } });
  expect(getByLabelText('acs_base_url_field')).toHaveAttribute('value', 'https://test_url.com/pulp/content');
  fireEvent.change(getByLabelText('acs_subpath_field'), { target: { value: 'test/repo1/,test/repo2/' } });

  // Mock content credential data
  const useContentCredentialSelectorMock = jest.spyOn(reactRedux, 'useSelector');
  useContentCredentialSelectorMock.mockReturnValue(contentCredentialResult.results);
  fireEvent.click(getByText('Next'));
  expect(queryByText('Manual authentication')).not.toBeInTheDocument();
  expect(queryByText('Content credentials')).toBeInTheDocument();
  const noAuthRadio = getAllByRole('radio', { name: 'None' })[0];
  fireEvent.click(noAuthRadio);
  useContentCredentialSelectorMock.mockRestore();
  fireEvent.click(getByText('Next'));
  const addAcsButton = getAllByRole('button', { name: 'Add' })[0];
  fireEvent.click(addAcsButton);

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  assertNockRequest(contentCredentialScope);
  assertNockRequest(productScope);
  assertNockRequest(smartProxyScope);
  assertNockRequest(createScope);
  done();
  act(done);
});

test('Can display create wizard and create simplified ACS', async (done) => {
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(ACSIndexPath)
    .query(true)
    .times(2)
    .reply(200, noResults);

  const contentCredentialScope = nockInstance
    .get(contentCredentialPath)
    .query(true)
    .reply(200, contentCredentialResult);

  const smartProxyScope = nockInstance
    .get(smartProxyPath)
    .query(true)
    .reply(200, smartProxyResult);

  const productScope = nockInstance
    .get(productsPath)
    .query(true)
    .reply(200, productsResult);

  const createScope = nockInstance
    .post(ACSCreatePath, createSimplifiedACSDetails)
    .reply(201, { id: 22 });

  const {
    getByLabelText, getByText, queryByText, getAllByRole,
  } = renderWithRedux(withACSRoute(<ACSTable />), renderOptions);

  expect(queryByText("You currently don't have any alternate content sources.")).toBeNull();
  await patientlyWaitFor(() => expect(queryByText("You currently don't have any alternate content sources.")).toBeInTheDocument());
  expect(queryByText('Add source')).toBeInTheDocument();
  fireEvent.click(getByText('Add source'));

  // First step: Select source
  await patientlyWaitFor(() => {
    expect(getByText('Add an alternate content source')).toBeInTheDocument();
    expect(queryByText('Alternate content sources define new locations to download content from at repository or smart proxy sync time.')).toBeInTheDocument();
  });

  // Choose ACS type, content_type defaults to yum
  fireEvent.click(getByText('Simplified'));

  // Go to next step: Name source
  fireEvent.click(getByText('Next'));

  await patientlyWaitFor(() => {
    expect(getByText('Enter a name for your source.')).toBeInTheDocument();
  });
  // Enter Name
  fireEvent.change(getByLabelText('acs_name_field'), { target: { value: 'acs_simplified_test' } });

  // Mock smart proxy selector to go to next page
  const useSelectorMock = jest.spyOn(reactRedux, 'useSelector');
  useSelectorMock.mockReturnValue(smartProxyResult);
  fireEvent.click(getByText('Next'));
  fireEvent.click(getByLabelText('Add all'));
  useSelectorMock.mockClear();
  // Mock product selector to go to next page
  const useProductSelectorMock = jest.spyOn(reactRedux, 'useSelector');
  useProductSelectorMock.mockReturnValue(productsResult);
  fireEvent.click(getByText('Next'));
  fireEvent.click(getByLabelText('Add all'));

  fireEvent.click(getByText('Next'));
  useProductSelectorMock.mockClear();
  const addAcsButton = getAllByRole('button', { name: 'Add' })[0];
  fireEvent.click(addAcsButton);

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  assertNockRequest(productScope);
  assertNockRequest(contentCredentialScope);
  assertNockRequest(smartProxyScope);
  assertNockRequest(createScope);
  done();
  act(done);
});
