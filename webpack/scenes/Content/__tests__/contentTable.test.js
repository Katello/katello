import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest, mockAutocomplete } from '../../../test-utils/nockWrapper';
import api from '../../../services/api';
import GenericContentPage from '../GenericContentPage';
import ansibleCollectionsResponse from './ansibleCollections.fixtures';
import contentTypesResponse from './contentTypes.fixtures.json';
import pythonPackagesResponse from './pythonPackages.fixtures.json';
import filesResponse from './files.fixtures.json';
import moduleStreamsResponse from './moduleStreams.fixtures.json';
import ContentTable from '../Table/ContentTable';

const contentTypesPath = api.getApiUrl('/repositories/content_types');
const pythonPackagesPath = api.getApiUrl('/python_packages');
const ansibleCollectionsPath = api.getApiUrl('/ansible_collections');
const filesPath = api.getApiUrl('/files');
const moduleStreamsPath = api.getApiUrl('/module_streams');

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
    renderWithRedux(<GenericContentPage />);

  expect(queryByText(firstPackage.name)).toBeNull();
  await patientlyWaitFor(() => {
    expect(getAllByText(firstPackage.name)[0]).toBeInTheDocument();
    expect(getAllByText(firstPackage.version)[0]).toBeInTheDocument();
    expect(getAllByText(firstPackage.filename)[0]).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(contentTypesScope);
  assertNockRequest(pythonPackagesScope);
  done();
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
  assertNockRequest(ansibleCollections);
  done();
});

test('Can call API for Files and show table on page load', async (done) => {
  const mockContentTypes = { Files: ['file', 'files'] };
  const autocompleteUrl = '/files/auto_complete_search';
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const { results } = filesResponse;
  const [firstFile] = results;

  const filesScope = nockInstance
    .get(filesPath)
    .query(true)
    .reply(200, filesResponse);

  const { queryByText, getAllByText } =
    renderWithRedux(<ContentTable
      contentTypes={mockContentTypes}
      selectedContentType="Files"
      setSelectedContentType={() => { }}
      showContentTypeSelector={false}
    />);

  expect(queryByText(firstFile.name)).toBeNull();
  await patientlyWaitFor(() => {
    expect(getAllByText(firstFile.name)[0]).toBeInTheDocument();
    expect(getAllByText(firstFile.path)[0]).toBeInTheDocument();
    expect(getAllByText(firstFile.checksum)[0]).toBeInTheDocument();
  });
  await patientlyWaitFor(() => {
    expect(autocompleteScope.isDone()).toBe(true);
    expect(filesScope.isDone()).toBe(true);
  });
  autocompleteScope.done();
  filesScope.done();
  done();
});

test('Can call API for Module Streams and show table on page load', async (done) => {
  const mockContentTypes = { 'Module Streams': ['modulemd', 'module_streams'] };
  const autocompleteUrl = '/module_streams/auto_complete_search';
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const { results } = moduleStreamsResponse;
  const [firstModuleStream] = results;

  const moduleStreamsScope = nockInstance
    .get(moduleStreamsPath)
    .query(true)
    .reply(200, moduleStreamsResponse);

  const { queryByText, getAllByText } =
    renderWithRedux(<ContentTable
      contentTypes={mockContentTypes}
      selectedContentType="Module Streams"
      setSelectedContentType={() => { }}
      showContentTypeSelector={false}
    />);

  expect(queryByText(firstModuleStream.name)).toBeNull();
  await patientlyWaitFor(() => {
    expect(getAllByText(firstModuleStream.name)[0]).toBeInTheDocument();
    expect(getAllByText(firstModuleStream.stream)[0]).toBeInTheDocument();
    expect(getAllByText(firstModuleStream.version)[0]).toBeInTheDocument();
    expect(getAllByText(firstModuleStream.arch)[0]).toBeInTheDocument();
    expect(getAllByText(firstModuleStream.context)[0]).toBeInTheDocument();
  });
  await patientlyWaitFor(() => {
    expect(autocompleteScope.isDone()).toBe(true);
    expect(moduleStreamsScope.isDone()).toBe(true);
  });
  autocompleteScope.done();
  moduleStreamsScope.done();
  done();
});
