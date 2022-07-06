import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest, mockAutocomplete, mockSetting } from '../../../test-utils/nockWrapper';
import api from '../../../services/api';
import ContentPage from '../ContentPage';
import ansibleCollectionsResponse from './ansibleCollections.fixtures';
import contentTypesResponse from './contentTypes.fixtures.json';
import pythonPackagesResponse from './pythonPackages.fixtures.json';
import ContentTable from '../Table/ContentTable';

const contentTypesPath = api.getApiUrl('/repositories/content_types');
const pythonPackagesPath = api.getApiUrl('/python_packages');
const ansibleCollectionsPath = api.getApiUrl('/ansible_collections');

let searchDelayScope;
let autoSearchScope;

beforeEach(() => {
  searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 0);
  autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing');
});

afterEach(() => {
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
    expect(getAllByText(firstPackage.filename)[0]).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(contentTypesScope);
  assertNockRequest(pythonPackagesScope, done);
});

test('Can call API for Ansible collections and show table on page load', async (done) => {
  const mockContentTypes = { 'Ansible Collections': ['ansible_collection', 'ansible_collections'] };
  const autocompleteUrl = '/ansible_collections/auto_complete_search';
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const { results } = ansibleCollectionsResponse;
  const [firstPackage] = results;

  const ansibleCollections = nockInstance
    .get(ansibleCollectionsPath)
    .query(true)
    .reply(200, ansibleCollectionsResponse);

  const { queryByText, getAllByText } =
    renderWithRedux(<ContentTable
      contentTypes={mockContentTypes}
      selectedContentType="Ansible Collections"
      setSelectedContentType={() => { }}
      showContentTypeSelector={false}
    />);

  expect(queryByText(firstPackage.name)).toBeNull();
  await patientlyWaitFor(() => {
    expect(getAllByText(firstPackage.name)[0]).toBeInTheDocument();
    expect(getAllByText(firstPackage.version)[0]).toBeInTheDocument();
    expect(getAllByText(firstPackage.checksum)[0]).toBeInTheDocument();
  });
  assertNockRequest(autocompleteScope);
  assertNockRequest(ansibleCollections, done);
});
