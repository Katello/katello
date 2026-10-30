import React from 'react';
import { Route } from 'react-router-dom';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest, mockAutocomplete } from '../../../../test-utils/nockWrapper';
import api from '../../../../services/api';
import { CONTENT_ID_KEY } from '../../ContentConstants';
import ContentDetails from '../ContentDetails';
import ContentRepositories from '../ContentRepositories';
import pythonPackageDetailsResponse from './pythonPackageDetails.fixtures.json';
import pythonPackageRepositoryDetailsResponse from './pythonPackageRepositoryDetails.fixtures.json';
import ansibleCollectionDetailsResponse from './ansibleCollectionDetails.fixtures.json';
import ansibleCollectionRepositoryDetailsResponse from './ansibleCollectionRepositoryDetails.fixtures.json';

const pythonPackageDetailsPath = api.getApiUrl('/python_packages/1491');
const ansibleCollectionDetailsPath = api.getApiUrl('/ansible_collections/51');
const contentRepositoryDetailsPath = api.getApiUrl('/repositories');

const withContentRoute = component => <Route path="/content/:content_type([a-z_]+)/:id([0-9]+)">{component}</Route>;

test('Can call API for Python package details and show details tab on page load', async (done) => {
  const renderOptions = {
    apiNamespace: CONTENT_ID_KEY,
    routerParams: {
      initialEntries: [{ pathname: '/content/python_packages/1491', hash: '#/details' }],
      initialIndex: 1,
    },
  };

  const {
    name, version, filename, additional_metadata: additionalMetadata,
  } = pythonPackageDetailsResponse;
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
    expect(getAllByText(filename)[0]).toBeInTheDocument();
    expect(getAllByText(additionalMetadata.sha256)[0]).toBeInTheDocument();
    expect(getAllByText(additionalMetadata.package_type)[0]).toBeInTheDocument();
    expect(getByLabelText('content_breadcrumb')).toBeInTheDocument();
    expect(getByLabelText('content_breadcrumb_content')).toHaveTextContent(name);
  });

  assertNockRequest(pythonPackagesScope);
  done();
});

test('Can call API for Python package repository details and show repositories tab', async (done) => {
  const autocompleteUrl = '/repositories/auto_complete_search';
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const results = pythonPackageRepositoryDetailsResponse.results[0];
  const repoName = results.name;
  const productName = results.product.name;
  const lastSyncWords = `${results.last_sync_words} ago`;
  const contentCountWords = '1489 Python packages';

  const pythonPackageRepositoryDetailsScope = nockInstance
    .get(contentRepositoryDetailsPath)
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

  assertNockRequest(autocompleteScope);
  assertNockRequest(pythonPackageRepositoryDetailsScope);
  done();
});

test('Can call API for Ansible collection details and show details tab on page load', async (done) => {
  const renderOptions = {
    apiNamespace: CONTENT_ID_KEY,
    routerParams: {
      initialEntries: [{ pathname: '/content/ansible_collections/51', hash: '#/details' }],
      initialIndex: 1,
    },
  };

  const { name, version } = ansibleCollectionDetailsResponse;
  const ansibleCollectionsScope = nockInstance
    .get(ansibleCollectionDetailsPath)
    .query(true)
    .reply(200, ansibleCollectionDetailsResponse);

  const { queryByText, getAllByText, getByLabelText } =
    renderWithRedux(withContentRoute(<ContentDetails />), renderOptions);

  expect(queryByText(name)).toBeNull();
  await patientlyWaitFor(() => {
    expect(getAllByText(name)[0]).toBeInTheDocument();
    expect(getAllByText(version)[0]).toBeInTheDocument();
    expect(getByLabelText('content_breadcrumb')).toBeInTheDocument();
    expect(getByLabelText('content_breadcrumb_content')).toHaveTextContent(name);
  });

  assertNockRequest(ansibleCollectionsScope);
  done();
});

test('Can call API for Ansible collection repository details and show repositories tab', async (done) => {
  const autocompleteUrl = '/repositories/auto_complete_search';
  const autocompleteScope = mockAutocomplete(nockInstance, autocompleteUrl);

  const results = ansibleCollectionRepositoryDetailsResponse.results[0];
  const repoName = results.name;
  const productName = results.product.name;
  const lastSyncWords = `${results.last_sync_words} ago`;
  const contentCountWords = '17 Ansible collections';

  const ansibleCollectionRepositoryDetailsScope = nockInstance
    .get(contentRepositoryDetailsPath)
    .query(true)
    .reply(200, ansibleCollectionRepositoryDetailsResponse);

  const { queryByText, getAllByText } =
    renderWithRedux(<ContentRepositories tabKey="repositories" id={51} contentType="ansible_collections" />);

  expect(queryByText(repoName)).toBeNull();
  await patientlyWaitFor(() => {
    expect(getAllByText(repoName)[0]).toBeInTheDocument();
    expect(getAllByText(productName)[0]).toBeInTheDocument();
    expect(getAllByText(lastSyncWords)[0]).toBeInTheDocument();
    expect(getAllByText(contentCountWords)[0]).toBeInTheDocument();
  });

  assertNockRequest(autocompleteScope);
  assertNockRequest(ansibleCollectionRepositoryDetailsScope);
  done();
});

// Optional File-details tests: uncomment to enable.
// test('shows File metadata above the content views tab', async () => {
//   const detailsScope = nockInstance.get(api.getApiUrl('/files/248'))
//     .query(true).reply(200, {
//       id: 248, name: '100.iso', path: 'images/100.iso', checksum: 'abc123',
//     });
//   const versionsScope = nockInstance.get(api.getApiUrl('/content_view_versions'))
//     .query(query => query.file_id === '248').reply(200, {
//       results: [], total: 0, subtotal: 0, page: 1, per_page: 20,
//     });
//   const autocompleteScope = mockAutocomplete(nockInstance, '/content_view_versions/auto_complete_search');
//   const { getByText, getByLabelText } = renderWithRedux(
//     withContentRoute(<ContentDetails />),
//     {
//       apiNamespace: CONTENT_ID_KEY,
//       routerParams: {
//         initialEntries: [{ pathname: '/content/files/248', hash: '#/content_views' }],
//       },
//     },
//   );
//   await patientlyWaitFor(() => {
//     expect(getByText('images/100.iso')).toBeInTheDocument();
//     expect(getByText('abc123')).toBeInTheDocument();
//     expect(getByLabelText('content_breadcrumb_content')).toHaveTextContent('100.iso');
//     expect(getByText('No Content Views contain this File')).toBeInTheDocument();
//   });
//   detailsScope.done();
//   versionsScope.done();
//   autocompleteScope.done();
// });
//
// test('shows an error when File details cannot be loaded', async () => {
//   const scope = nockInstance.get(api.getApiUrl('/files/999999999'))
//     .query(true).reply(404, {
//       error: { message: 'File not found', details: '' },
//     });
//   const { getByText } = renderWithRedux(
//     withContentRoute(<ContentDetails />),
//     {
//       apiNamespace: CONTENT_ID_KEY,
//       routerParams: {
//         initialEntries: [{ pathname: '/content/files/999999999' }],
//       },
//     },
//   );
//   await patientlyWaitFor(() => {
//     expect(getByText('File not found')).toBeInTheDocument();
//   });
//   scope.done();
// });
