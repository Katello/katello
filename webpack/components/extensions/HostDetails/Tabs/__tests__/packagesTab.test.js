import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import * as hooks from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import { nockInstance, assertNockRequest, mockForemanAutocomplete } from '../../../../../test-utils/nockWrapper';
import { foremanApi } from '../../../../../services/api';
import { HOST_PACKAGES_KEY, PACKAGES_SEARCH_QUERY, SELECTED_UPDATE_VERSIONS } from '../PackagesTab/HostPackagesConstants';
import { PackagesTab } from '../PackagesTab/PackagesTab.js';
import mockPackagesData from './packages.fixtures.json';
import { REX_FEATURES } from '../RemoteExecutionConstants';

jest.mock('../../hostDetailsHelpers', () => ({
  ...jest.requireActual('../../hostDetailsHelpers'),
  userPermissionsFromHostDetails: () => ({
    create_job_invocations: true,
    edit_hosts: true,
  }),
}));

const contentFacetAttributes = {
  id: 11,
  uuid: 'e5761ea3-4117-4ecf-83d0-b694f99b389e',
  content_view_default: false,
  lifecycle_environment_library: false,
};

const hostname = 'test-host.example.com';
const renderOptions = (facetAttributes = contentFacetAttributes) => ({
  apiNamespace: HOST_PACKAGES_KEY,
  initialState: {
    API: {
      HOST_DETAILS: {
        response: {
          id: 1,
          name: hostname,
          content_facet_attributes: { ...facetAttributes },
          display_name: hostname,
        },
        status: 'RESOLVED',
      },
    },
  },
});

const hostPackages = foremanApi.getApiUrl('/hosts/1/packages');
const jobInvocations = foremanApi.getApiUrl('/job_invocations');
const autocompleteUrl = '/hosts/1/packages/auto_complete_search';
const baseQuery = {
  include_latest_upgradable: true,
  per_page: 20,
  page: 1,
};

const defaultQueryWithoutSearch = {
  ...baseQuery,
  sort_by: 'nvra',
  sort_order: 'asc',
};
const defaultQuery = { ...defaultQueryWithoutSearch, search: '' };

let firstPackage;
let secondPackage;

beforeEach(() => {
  const { results } = mockPackagesData;
  [firstPackage, secondPackage] = results;
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
  await patientlyWaitFor(() => expect(getAllByText(firstPackage.name)[0]).toBeInTheDocument());
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
    .reply(200, { ...mockPackagesData, results: [firstPackage] });

  const {
    queryByText,
    getByRole,
    getAllByText,
    getByText,
  } = renderWithRedux(<PackagesTab />, renderOptions());

  await patientlyWaitFor(() => expect(getAllByText(firstPackage.name)[0]).toBeInTheDocument());
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
  assertNockRequest(scope2, done); // Pass jest callback to confirm test is done
});

test('Can upgrade a package via remote execution', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

  const scope = nockInstance
    .get(hostPackages)
    .query(defaultQuery)
    .reply(200, mockPackagesData);

  const statusScope = nockInstance
    .get(hostPackages)
    .query({ ...defaultQuery, status: 'upgradable' })
    .reply(200, { ...mockPackagesData, results: [firstPackage] });

  const upgradeScope = nockInstance
    .post(jobInvocations, {
      job_invocation: {
        inputs: {
          package: firstPackage.upgradable_versions[0],
        },
        search_query: `name ^ (${hostname})`,
        feature: REX_FEATURES.KATELLO_PACKAGE_UPDATE,
      },
    })
    .reply(201);

  const {
    getByRole,
    getAllByText,
    getByLabelText,
    getByText,
  } = renderWithRedux(<PackagesTab />, renderOptions());

  await patientlyWaitFor(() => expect(getAllByText(firstPackage.name)[0]).toBeInTheDocument());

  const statusDropdown = getByText('Status', { ignore: 'th' });
  expect(statusDropdown).toBeInTheDocument();
  fireEvent.click(statusDropdown);
  const upgradable = getByRole('option', { name: 'select Upgradable' });
  fireEvent.click(upgradable);
  await patientlyWaitFor(() => {
    expect(getByText('coreutils')).toBeInTheDocument();
  });

  const kebabDropdown = getByLabelText('Actions');
  kebabDropdown.click();

  const rexAction = getByText('Upgrade via remote execution');
  await patientlyWaitFor(() => expect(rexAction).toBeInTheDocument());
  fireEvent.click(rexAction);

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  assertNockRequest(statusScope);
  assertNockRequest(upgradeScope, done);
});

test('Can upgrade a package via customized remote execution', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

  const scope = nockInstance
    .get(hostPackages)
    .query(defaultQuery)
    .reply(200, mockPackagesData);

  const statusScope = nockInstance
    .get(hostPackages)
    .query({ ...defaultQuery, status: 'upgradable' })
    .reply(200, { ...mockPackagesData, results: [firstPackage] });

  const {
    getByRole,
    getAllByText,
    getByLabelText,
    getByText,
  } = renderWithRedux(<PackagesTab />, renderOptions());

  await patientlyWaitFor(() => expect(getAllByText(firstPackage.name)[0]).toBeInTheDocument());

  const statusDropdown = getByText('Status', { ignore: 'th' });
  expect(statusDropdown).toBeInTheDocument();
  fireEvent.click(statusDropdown);
  const upgradable = getByRole('option', { name: 'select Upgradable' });
  fireEvent.click(upgradable);
  await patientlyWaitFor(() => {
    expect(getByText('coreutils')).toBeInTheDocument();
  });

  const kebabDropdown = getByLabelText('Actions');
  kebabDropdown.click();

  const rexAction = getByText('Upgrade via customized remote execution');
  const feature = REX_FEATURES.KATELLO_PACKAGE_UPDATE;
  const packageName = firstPackage.upgradable_versions[0];

  expect(rexAction).toBeInTheDocument();
  expect(rexAction).toHaveAttribute(
    'href',
    `/job_invocations/new?feature=${feature}&search=name%20%5E%20(${hostname})&inputs%5Bpackage%5D=${packageName}`,
  );

  fireEvent.click(rexAction);

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  assertNockRequest(statusScope, done);
});

test('Can bulk upgrade via remote execution', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

  const scope = nockInstance
    .get(hostPackages)
    .query(defaultQuery)
    .reply(200, mockPackagesData);

  const upgradeScope = nockInstance
    .post(jobInvocations, {
      job_invocation: {
        inputs: {
          [PACKAGES_SEARCH_QUERY]: `id ^ (${firstPackage.id},${secondPackage.id})`,
          [SELECTED_UPDATE_VERSIONS]: JSON.stringify([]),
        },
        search_query: `name ^ (${hostname})`,
        feature: REX_FEATURES.KATELLO_PACKAGES_UPDATE_BY_SEARCH,
        description_format: 'Upgrade package(s) chrony, coreutils',
      },
    })
    .reply(201);

  const {
    getAllByRole,
    getAllByText,
    getByRole,
    getByLabelText,
  } = renderWithRedux(<PackagesTab />, renderOptions());

  await patientlyWaitFor(() => expect(getAllByText(firstPackage.name)[0]).toBeInTheDocument());

  getByRole('checkbox', { name: 'Select row 0' }).click();
  expect(getByLabelText('Select row 0').checked).toEqual(true);
  getByRole('checkbox', { name: 'Select row 1' }).click();
  expect(getByLabelText('Select row 1').checked).toEqual(true);

  const upgradeDropdown = getAllByRole('button', { name: 'Select' })[1];
  fireEvent.click(upgradeDropdown);

  const rexAction = getByLabelText('bulk_upgrade_rex');
  expect(rexAction).toBeInTheDocument();
  fireEvent.click(rexAction);

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope);
  assertNockRequest(upgradeScope, done);
});

test('Can bulk upgrade via customized remote execution', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

  const scope = nockInstance
    .get(hostPackages)
    .query(defaultQuery)
    .reply(200, mockPackagesData);

  const {
    getAllByRole,
    getAllByText,
    getByRole,
    getByLabelText,
  } = renderWithRedux(<PackagesTab />, renderOptions());

  await patientlyWaitFor(() => expect(getAllByText(firstPackage.name)[0]).toBeInTheDocument());

  const feature = REX_FEATURES.KATELLO_PACKAGES_UPDATE_BY_SEARCH;
  const packages = `${firstPackage.id},${secondPackage.id}`;
  const job =
    `/job_invocations/new?feature=${feature}&search=name%20%5E%20(${hostname})&inputs%5BPackages%20search%20query%5D=id%20%5E%20(${packages})&inputs%5BSelected%20update%20versions%5D=%5B%5D`;

  getByRole('checkbox', { name: 'Select row 0' }).click();
  expect(getByLabelText('Select row 0').checked).toEqual(true);
  getByRole('checkbox', { name: 'Select row 1' }).click();
  expect(getByLabelText('Select row 1').checked).toEqual(true);

  const upgradeDropdown = getAllByRole('button', { name: 'Select' })[1];
  fireEvent.click(upgradeDropdown);
  expect(upgradeDropdown).not.toHaveAttribute('disabled');

  const rexAction = getByLabelText('bulk_upgrade_customized_rex');
  expect(rexAction).toBeInTheDocument();
  expect(rexAction).toHaveAttribute('href', job);

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
});

test('Upgrade is disabled when there are non-upgradable packages selected', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

  const scope = nockInstance
    .get(hostPackages)
    .query(defaultQuery)
    .reply(200, mockPackagesData);

  const {
    getAllByRole,
    getAllByText,
    getByLabelText,
    getByRole,
  } = renderWithRedux(<PackagesTab />, renderOptions());

  await patientlyWaitFor(() => expect(getAllByText(firstPackage.name)[0]).toBeInTheDocument());

  // select an upgradable package
  getByRole('checkbox', { name: 'Select row 0' }).click();
  // select an up-to-date package
  getByRole('checkbox', { name: 'Select row 2' }).click();
  expect(getByLabelText('Select row 2').checked).toEqual(true);

  const upgradeDropdown = getAllByRole('button', { name: 'Select' })[1];
  expect(upgradeDropdown).toHaveAttribute('disabled');

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
});

test('Remove is disabled when in select all mode', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(hostPackages)
    .query(defaultQuery)
    .reply(200, mockPackagesData);

  const {
    getAllByText, getByRole,
  } = renderWithRedux(<PackagesTab />, renderOptions());

  await patientlyWaitFor(() => expect(getAllByText(firstPackage.name)[0]).toBeInTheDocument());

  // find and click the select all checkbox
  const selectAllCheckbox = getByRole('checkbox', { name: 'Select all' });
  fireEvent.click(selectAllCheckbox);
  getByRole('button', { name: 'bulk_actions' }).click();

  const removeButton = getByRole('menuitem', { name: 'bulk_remove' });
  await patientlyWaitFor(() => expect(removeButton).toBeInTheDocument());
  expect(removeButton).toHaveAttribute('aria-disabled', 'true');

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
});

test('Sets initial search query from url params', async (done) => {
  // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(hostPackages)
    .query({ ...defaultQuery, search: `name=${firstPackage.name}` })
    .reply(200, { ...mockPackagesData, results: [firstPackage] });

  jest.spyOn(hooks, 'useUrlParams').mockImplementation(() => ({
    searchParam: `name=${firstPackage.name}`,
  }));

  const { getAllByText, queryByText } = renderWithRedux(<PackagesTab />, renderOptions());

  await patientlyWaitFor(() => expect(getAllByText(firstPackage.name)[0]).toBeInTheDocument());
  expect(queryByText(secondPackage.name)).not.toBeInTheDocument();

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});

