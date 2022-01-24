import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent, within } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest, mockForemanAutocomplete, mockSetting } from '../../../../../test-utils/nockWrapper';
import katelloApi from '../../../../../services/api';
import mockPackagesData from './packages.fixtures.json';
import PackageInstallModal from '../PackageInstallModal';
import { HOST_YUM_INSTALLABLE_PACKAGES_KEY } from '../../YumInstallablePackages/YumInstallablePackagesConstants';

const contentFacetAttributes = {
  id: 11,
  uuid: 'e5761ea3-4117-4ecf-83d0-b694f99b389e',
  content_view_default: false,
  lifecycle_environment_library: false,
};

const renderOptions = (facetAttributes = contentFacetAttributes) => ({
  apiNamespace: HOST_YUM_INSTALLABLE_PACKAGES_KEY,
  initialState: {
    API: {
      HOST_DETAILS: {
        response: {
          id: 1,
          name: 'test-host',
          content_facet_attributes: { ...facetAttributes },
        },
        status: 'RESOLVED',
      },
    },
  },
});

const hostYumInstallablePackages = katelloApi.getApiUrl('/packages');
const autocompleteUrl = '/hosts/1/packages/auto_complete_search';
const defaultQuery = {
  packages_restrict_not_installed: true,
  packages_restrict_applicable: false,
  packages_restrict_latest: true,
  host_id: 1,
  per_page: 20,
  page: 1,
};

let firstPackages;
let searchDelayScope;
let autoSearchScope;

beforeEach(() => {
  const { results } = mockPackagesData;
  [firstPackages] = results;
  searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 500);
  autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing', true);
});

afterEach(() => {
  assertNockRequest(searchDelayScope);
  assertNockRequest(autoSearchScope);
});

test('Can call API for installable packages and show on screen on page load', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

  const scope = nockInstance
    .get(hostYumInstallablePackages)
    .query(defaultQuery)
    .reply(200, mockPackagesData);

  const { getAllByText }
     = renderWithRedux(<PackageInstallModal
       isOpen
       closeModal={jest.fn()}
       hostId={1}
       hostName="test-host"
       showKatelloAgent={false}
     />, renderOptions());

  // Assert that the packages are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(getAllByText(firstPackages.name)[0]).toBeInTheDocument());
  // Assert request was made and completed, see helper function
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});

test('Can handle no installable packages being present', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

  const noResults = {
    total: 0,
    subtotal: 0,
    page: 1,
    per_page: 20,
    results: [],
  };

  const scope = nockInstance
    .get(hostYumInstallablePackages)
    .query(defaultQuery)
    .reply(200, noResults);

  const { queryByText }
    = renderWithRedux(<PackageInstallModal
      isOpen
      closeModal={jest.fn()}
      hostId={1}
      hostName="test-host"
      showKatelloAgent={false}
    />, renderOptions());

  // Assert that there are not any packages showing on the screen.
  await patientlyWaitFor(() => expect(queryByText('No packages available to install')).toBeInTheDocument());
  // Assert request was made and completed, see helper function
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});

test('Does not show katello-agent option when disabled', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

  const scope = nockInstance
    .get(hostYumInstallablePackages)
    .query(defaultQuery)
    .reply(200, mockPackagesData);

  const {
    getAllByText, getByText, getByRole, queryByText,
  } = renderWithRedux(<PackageInstallModal
    isOpen
    closeModal={jest.fn()}
    hostId={1}
    hostName="test-host"
    showKatelloAgent={false}
  />, renderOptions());

  // Assert that the packages are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(getAllByText(firstPackages.name)[0]).toBeInTheDocument());
  // Assert request was made and completed, see helper function
  // find the first table row's checkbox
  const checkbox = getByRole('checkbox', { name: 'Select row 0' });
  // click the checkbox to make sure the Install dropdown will be enabled
  fireEvent.click(checkbox);
  const footer = getByRole('contentinfo');
  // find the dropdown to the right of the Install button
  // (no, the other one! The one that's in the footer.)
  const dropdown = await patientlyWaitFor(() => within(footer).getByRole('button', { name: 'Select' }));
  fireEvent.click(dropdown);
  expect(getByText('Install via remote execution')).toBeInTheDocument();
  // Assert that the katello-agent option is not present
  expect(queryByText('katello-agent')).not.toBeInTheDocument();

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});

test('Shows the katello-agent option when enabled', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

  const scope = nockInstance
    .get(hostYumInstallablePackages)
    .query(defaultQuery)
    .reply(200, mockPackagesData);

  const {
    getAllByText, getByText, getByRole,
  } = renderWithRedux(<PackageInstallModal
    isOpen
    closeModal={jest.fn()}
    hostId={1}
    hostName="test-host"
    showKatelloAgent
  />, renderOptions());

  // Assert that the packages are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(getAllByText(firstPackages.name)[0]).toBeInTheDocument());
  // Assert request was made and completed, see helper function
  // find the first table row's checkbox
  const checkbox = getByRole('checkbox', { name: 'Select row 0' });
  // click the checkbox to make sure the Install dropdown will be enabled
  fireEvent.click(checkbox);
  const footer = getByRole('contentinfo');
  const dropdown = await patientlyWaitFor(() => within(footer).getByRole('button', { name: 'Select' }));
  fireEvent.click(dropdown);
  expect(getByText('Install via remote execution')).toBeInTheDocument();
  // Assert that the katello-agent option is not present
  expect(getByText('Install via katello-agent')).toBeInTheDocument();

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});
