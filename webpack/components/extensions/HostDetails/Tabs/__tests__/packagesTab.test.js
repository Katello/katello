import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
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
          content_facet_attributes: { ...facetAttributes },
        },
        status: 'RESOLVED',
      },
    },
  },
});

const hostPackages = foremanApi.getApiUrl('/hosts/1/packages?include_latest_upgradable=true&per_page=20&page=1');
const autocompleteUrl = '/hosts/1/packages/auto_complete_search';

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

test('Can call API for packages and show on screen on page load', async (done) => {
  // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

  // return tracedata results when we look for packages
  const scope = nockInstance
    .get(hostPackages)
    .reply(200, mockPackagesData);

  const { getAllByText } = renderWithRedux(<PackagesTab />, renderOptions());

  // Assert that the packages are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(getAllByText(firstPackages.name)[0]).toBeInTheDocument());
  // Assert request was made and completed, see helper function
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});

test('Can handle no packags being present', async (done) => {
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
    .reply(200, noResults);

  const { queryByText } = renderWithRedux(<PackagesTab />, renderOptions());

  // Assert that there are not any packages showing on the screen.
  await patientlyWaitFor(() => expect(queryByText('This host does not have any packages.')).toBeInTheDocument());
  // Assert request was made and completed, see helper function
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});
