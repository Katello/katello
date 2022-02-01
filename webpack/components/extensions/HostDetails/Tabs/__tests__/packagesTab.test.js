import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest, mockForemanAutocomplete, mockSetting } from '../../../../../test-utils/nockWrapper';
import { foremanApi } from '../../../../../services/api';
import { HOST_PACKAGES_KEY } from '../../HostPackages/HostPackagesConstants';
import { PackagesTab } from '../PackagesTab';
import mockPackagesData from './packages.fixtures.json';

const contentFacetAttributes = {
  id: 11,
  uuid: 'e5761ea3-4117-4ecf-83d0-b694f99b389e',
  content_view_default: false,
  lifecycle_environment_library: false,
};

const renderOptions = (facetAttributes = contentFacetAttributes) => ({
  apiNamespace: HOST_PACKAGES_KEY,
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

const hostPackages = foremanApi.getApiUrl('/hosts/1/packages');
const autocompleteUrl = '/hosts/1/packages/auto_complete_search';
const defaultQueryWithoutSearch = {
  include_latest_upgradable: true,
  per_page: 20,
  page: 1,
};
const defaultQuery = { ...defaultQueryWithoutSearch, search: '' };

let firstPackages;
let searchDelayScope;
let autoSearchScope;

beforeEach(() => {
  const { results } = mockPackagesData;
  [firstPackages] = results;
  searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 0);
  autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing');
});

afterEach(() => {
  assertNockRequest(searchDelayScope);
  assertNockRequest(autoSearchScope);
});

test('Can call API for packages and show on screen on page load', async (done) => {
  // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(hostPackages)
    .query(defaultQuery)
    .reply(200, mockPackagesData);

  const { getAllByText } = renderWithRedux(<PackagesTab />, renderOptions());

  // Assert that the packages are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(getAllByText(firstPackages.name)[0]).toBeInTheDocument());
  // Assert request was made and completed, see helper function
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});

test('Can handle no packages being present', async (done) => {
  // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

  const noResults = {
    total: 0,
    subtotal: 0,
    page: 1,
    per_page: 20,
    results: [],
  };

  const scope = nockInstance
    .get(hostPackages)
    .query(defaultQuery)
    .reply(200, noResults);

  const { queryByText } = renderWithRedux(<PackagesTab />, renderOptions());

  // Assert that there are not any packages showing on the screen.
  await patientlyWaitFor(() => expect(queryByText('This host does not have any packages.')).toBeInTheDocument());
  // Assert request was made and completed, see helper function
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});

test('Can filter by package status', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(hostPackages)
    .query(defaultQuery)
    .reply(200, mockPackagesData);

  const scope2 = nockInstance
    .get(hostPackages)
    .query({ ...defaultQuery, status: 'upgradable' })
    .reply(200, { ...mockPackagesData, results: [firstPackages] });

  const {
    queryByText,
    getByRole,
    getAllByText,
    getByText,
  } = renderWithRedux(<PackagesTab />, renderOptions());

  // Assert that the errata are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(getAllByText(firstPackages.name)[0]).toBeInTheDocument());
  // the Upgradable text in the table is just a text node, while the dropdown is a button
  expect(getByText('Up-to date', { ignore: ['button', 'title'] })).toBeInTheDocument();
  expect(getByText('coreutils', { ignore: ['button', 'title'] })).toBeInTheDocument();
  expect(getByText('acl', { ignore: ['button', 'title'] })).toBeInTheDocument();

  const statusDropdown = queryByText('Status', { ignore: 'th' });
  expect(statusDropdown).toBeInTheDocument();
  fireEvent.click(statusDropdown);
  const upgradable = getByRole('option', { name: 'select Upgradable' });
  fireEvent.click(upgradable);
  await patientlyWaitFor(() => {
    expect(queryByText('coreutils')).toBeInTheDocument();
    expect(queryByText('acl')).not.toBeInTheDocument();
  });


  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  assertNockRequest(searchDelayScope);
  assertNockRequest(autoSearchScope);
  assertNockRequest(scope2, done); // Pass jest callback to confirm test is done
});
