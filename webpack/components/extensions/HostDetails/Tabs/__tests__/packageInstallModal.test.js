import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent, within } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest, mockForemanAutocomplete } from '../../../../../test-utils/nockWrapper';
import katelloApi from '../../../../../services/api';
import mockPackagesData from './yumInstallablePackages.fixtures.json';
import PackageInstallModal from '../PackagesTab/PackageInstallModal';
import { HOST_YUM_INSTALLABLE_PACKAGES_KEY } from '../PackagesTab/YumInstallablePackagesConstants';
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

const renderOptions = (facetAttributes = contentFacetAttributes) => ({
  apiNamespace: HOST_YUM_INSTALLABLE_PACKAGES_KEY,
  initialState: {
    API: {
      HOST_DETAILS: {
        response: {
          id: 1,
          name: 'test-host',
          content_facet_attributes: { ...facetAttributes },
          display_name: 'test-host',
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

beforeEach(() => {
  const { results } = mockPackagesData;
  [firstPackages] = results;
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
       triggerPackageInstall={jest.fn()}
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
      triggerPackageInstall={jest.fn()}
    />, renderOptions());

  // Assert that there are not any packages showing on the screen.
  await patientlyWaitFor(() => expect(queryByText('No packages available to install')).toBeInTheDocument());
  // Assert request was made and completed, see helper function
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});


test('Can install a package via remote execution', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(hostYumInstallablePackages)
    .query(defaultQuery)
    .reply(200, mockPackagesData);
  const triggerPackageInstall = jest.fn();

  const {
    getAllByText, getByText, getByRole,
  } = renderWithRedux(<PackageInstallModal
    isOpen
    closeModal={jest.fn()}
    hostId={1}
    hostName="test-host"
    triggerPackageInstall={triggerPackageInstall}
  />, renderOptions());

  await patientlyWaitFor(() => expect(getAllByText(firstPackages.name)[0]).toBeInTheDocument());
  // find and select the first two packages
  const checkbox1 = getByRole('checkbox', { name: 'Select row 0' });
  const checkbox2 = getByRole('checkbox', { name: 'Select row 1' });
  fireEvent.click(checkbox1);
  fireEvent.click(checkbox2);
  // click the Install dropdown
  const footer = getByRole('contentinfo');
  const dropdown = await patientlyWaitFor(() => within(footer).getByRole('button', { name: 'Select' }));
  fireEvent.click(dropdown);
  const rexOption = getByText('Install via remote execution');
  fireEvent.click(rexOption);

  expect(triggerPackageInstall).toHaveBeenCalled();
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
});

test('Can install a package via customized remote execution', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(hostYumInstallablePackages)
    .query(defaultQuery)
    .reply(200, mockPackagesData);

  const {
    getAllByText, queryByText, getByRole,
  } = renderWithRedux(<PackageInstallModal
    isOpen
    closeModal={jest.fn()}
    hostId={1}
    hostName="test-host"
    triggerPackageInstall={jest.fn()}
  />, renderOptions());

  await patientlyWaitFor(() => expect(getAllByText(firstPackages.name)[0]).toBeInTheDocument());
  // find and select the first two packages
  const checkbox1 = getByRole('checkbox', { name: 'Select row 0' });
  const checkbox2 = getByRole('checkbox', { name: 'Select row 1' });
  fireEvent.click(checkbox1);
  fireEvent.click(checkbox2);
  // click the Install dropdown
  const footer = getByRole('contentinfo');
  const dropdown = await patientlyWaitFor(() => within(footer).getByRole('button', { name: 'Select' }));
  fireEvent.click(dropdown);
  const customizedRexOption = queryByText('Install via customized remote execution');
  expect(customizedRexOption).toBeInTheDocument();
  expect(customizedRexOption).toHaveAttribute(
    'href',
    `/job_invocations/new?feature=${REX_FEATURES.KATELLO_PACKAGE_INSTALL}&search=name%20%5E%20(test-host)&inputs%5Bpackage%5D=duck,cheetah`,
  );
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
});

test('Uses package_install_by_search_query template when in select all mode', async (done) => {
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const scope = nockInstance
    .get(hostYumInstallablePackages)
    .query(defaultQuery)
    .reply(200, mockPackagesData);

  const {
    getAllByText, queryByText, getByRole,
  } = renderWithRedux(<PackageInstallModal
    isOpen
    closeModal={jest.fn()}
    hostId={1}
    hostName="test-host"
    triggerPackageInstall={jest.fn()}
  />, renderOptions());

  await patientlyWaitFor(() => expect(getAllByText(firstPackages.name)[0]).toBeInTheDocument());
  // find and click the select all checkbox
  const selectAllCheckbox = getByRole('checkbox', { name: 'Select all' });
  fireEvent.click(selectAllCheckbox);
  // find and deselect the first package
  const checkbox1 = getByRole('checkbox', { name: 'Select row 0' });
  fireEvent.click(checkbox1);
  // click the Install dropdown
  const footer = getByRole('contentinfo');
  const dropdown = await patientlyWaitFor(() => within(footer).getByRole('button', { name: 'Select' }));
  fireEvent.click(dropdown);
  const customizedRexOption = queryByText('Install via customized remote execution');
  expect(customizedRexOption).toBeInTheDocument();
  expect(customizedRexOption).toHaveAttribute(
    'href',
    `/job_invocations/new?feature=${REX_FEATURES.KATELLO_PACKAGE_INSTALL_BY_SEARCH}&search=name%20%5E%20(test-host)&inputs%5BPackage%20search%20query%5D=id%20!%5E%20(32376)`,
  );
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
});

