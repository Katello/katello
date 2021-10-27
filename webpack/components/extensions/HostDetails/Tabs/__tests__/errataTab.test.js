import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest, mockForemanAutocomplete, mockSetting } from '../../../../../test-utils/nockWrapper';
import { foremanApi } from '../../../../../services/api';
import { HOST_ERRATA_KEY } from '../../HostErrata/HostErrataConstants';
import { ErrataTab } from '../ErrataTab';
import mockErrataData from './errata.fixtures.json';

const renderOptions = {
  apiNamespace: HOST_ERRATA_KEY,
  initialState: {
    API: {
      HOST_DETAILS: {
        response: {
          id: 1,
        },
        status: 'RESOLVED',
      },
    },
  },
};

const makeMockErrata = ({ pageSize = 20, total = 100, page = 1 }) => {
  const mockErrataResults = [];
  for (let i = (page * 1000); i < (page * 1000) + pageSize; i += 1) {
    mockErrataResults.push({
      id: i,
      severity: 'Important',
      title: `Errata${i}`,
      type: (i % 2 === 0) ? 'security' : 'enhancement',
      host_id: 1,
      errata_id: `Errata${i}`,
      bugs: [],
      cves: [],
      packages: [],
      module_streams: [],
    });
  }

  return {
    total,
    subtotal: total,
    page,
    per_page: pageSize,
    error: null,
    search: null,
    results: mockErrataResults,
  };
};

const hostErrata = foremanApi.getApiUrl('/hosts/1/errata?per_page=20&page=1');
const autocompleteUrl = '/hosts/1/errata/auto_complete_search';

let firstErrata;
let searchDelayScope;
let autoSearchScope;

beforeEach(() => {
  // jest.resetModules();
  const { results } = mockErrataData;
  [firstErrata] = results;
  searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 500);
  autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing', true);
});

afterEach(() => {
  assertNockRequest(searchDelayScope);
  assertNockRequest(autoSearchScope);
});

test('Can call API for errata and show on screen on page load', async (done) => {
  // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

  // return tracedata results when we look for errata
  const scope = nockInstance
    .get(hostErrata)
    .reply(200, mockErrataData);

  const { getAllByText } = renderWithRedux(<ErrataTab />, renderOptions);

  // Assert that the errata are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(getAllByText(firstErrata.severity)[0]).toBeInTheDocument());
  // Assert request was made and completed, see helper function
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});

test('Can handle no errata being present', async (done) => {
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
    .get(hostErrata)
    .reply(200, noResults);

  const { queryByText } = renderWithRedux(<ErrataTab />, renderOptions);

  // Assert that there are not any errata showing on the screen.
  await patientlyWaitFor(() => expect(queryByText('This host does not have any installable errata.')).toBeInTheDocument());
  // Assert request was made and completed, see helper function
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});

test('Can display expanded errata details', async (done) => {
  // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

  // return tracedata results when we look for errata
  const scope = nockInstance
    .get(hostErrata)
    .reply(200, mockErrataData);

  const {
    getByText,
    queryByText,
    getAllByText,
    getAllByLabelText,
  } = renderWithRedux(<ErrataTab />, renderOptions);

  // Assert that the errata are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(getAllByText(firstErrata.severity)[0]).toBeInTheDocument());
  const firstExpansion = getAllByLabelText('Details')[0];

  firstExpansion.click();
  expect(getAllByText('CVEs').length).toBeGreaterThan(0);
  // the errata details should now be visible
  expect(getByText(firstErrata.summary)).toBeVisible();

  const cveTreeItem = getAllByText('CVEs')[0];
  expect(cveTreeItem).toBeVisible();
  cveTreeItem.click();
  // the CVE should now be visible
  expect(getByText(firstErrata.cves[0].cve_id)).toBeInTheDocument();
  cveTreeItem.click();
  // the CVE should now have disappeared
  expect(queryByText(firstErrata.cves[0].cve_id)).not.toBeInTheDocument();

  firstExpansion.click();
  // the errata details should now be hidden
  expect(getByText(firstErrata.summary)).not.toBeVisible();
  // Assert request was made and completed, see helper function
  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});

test('Can select one errata', async (done) => {
  // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);

  // return errata data results when we look for errata
  const scope = nockInstance
    .get(hostErrata)
    .reply(200, mockErrataData);

  const {
    queryByText,
    getAllByText,
    getByLabelText,
  } = renderWithRedux(<ErrataTab />, renderOptions);

  // Assert that the errata are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(getAllByText(firstErrata.severity)[0]).toBeInTheDocument());

  expect(queryByText('1 selected')).not.toBeInTheDocument();

  const firstCheckBox = getByLabelText('Select row 0');
  firstCheckBox.click();

  const selectAllCheckbox = getByLabelText('Select all');
  expect(selectAllCheckbox.checked).toEqual(false);

  expect(queryByText('1 selected')).toBeInTheDocument();

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});

test('Can select all errata across pages through checkbox', async (done) => {
  // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const mockErrata = makeMockErrata({ page: 1 });
  // return errata data results when we look for errata
  const page1 = foremanApi.getApiUrl('/hosts/1/errata?per_page=20&page=1');
  const page2 = foremanApi.getApiUrl('/hosts/1/errata?page=2&per_page=20');

  // return errata data results when we look for errata
  const scope = nockInstance
    .get(page1)
    .reply(200, mockErrata);

  const scope2 = nockInstance
    .get(page2)
    .reply(200, makeMockErrata({ page: 2 }));

  const {
    queryByText,
    getAllByText,
    getByLabelText,
    getAllByLabelText,
  } = renderWithRedux(<ErrataTab />, renderOptions);

  // Assert that the errata are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(getAllByText('Important')[0]).toBeInTheDocument());

  const selectAllCheckbox = getByLabelText('Select all');
  selectAllCheckbox.click();
  expect(queryByText(`${mockErrata.total} selected`)).toBeInTheDocument();
  expect(getByLabelText('Select row 0').checked).toEqual(true);

  getAllByLabelText('Go to next page')[0].click();
  await patientlyWaitFor(() => expect(getAllByText('Important')[0]).toBeInTheDocument());
  expect(getByLabelText('Select row 0').checked).toEqual(true);

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done);
  assertNockRequest(scope2, done); // Pass jest callback to confirm test is done
});

test('Can deselect all errata across pages through checkbox', async (done) => {
  // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const mockErrata = makeMockErrata({ page: 1 });
  // return errata data results when we look for errata
  const page1 = foremanApi.getApiUrl('/hosts/1/errata?per_page=20&page=1');
  const page2 = foremanApi.getApiUrl('/hosts/1/errata?page=2&per_page=20');

  // return errata data results when we look for errata
  const scope = nockInstance
    .get(page1)
    .reply(200, mockErrata);

  const scope2 = nockInstance
    .get(page2)
    .reply(200, makeMockErrata({ page: 2 }));

  const {
    queryByText,
    getAllByText,
    getByLabelText,
    getAllByLabelText,
  } = renderWithRedux(<ErrataTab />, renderOptions);

  // Assert that the errata are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(getAllByText('Important')[0]).toBeInTheDocument());

  const selectAllCheckbox = getByLabelText('Select all');
  selectAllCheckbox.click();
  expect(queryByText(`${mockErrata.total} selected`)).toBeInTheDocument();
  expect(getByLabelText('Select row 0').checked).toEqual(true);

  selectAllCheckbox.click();
  expect(queryByText(`${mockErrata.total} selected`)).not.toBeInTheDocument();
  expect(getByLabelText('Select row 0').checked).toEqual(false);

  getAllByLabelText('Go to next page')[0].click();
  await patientlyWaitFor(() => expect(getAllByText('Important')[0]).toBeInTheDocument());
  expect(getByLabelText('Select row 0').checked).toEqual(false);

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
  assertNockRequest(scope2, done);
});


test('Can select & deselect errata across pages', async (done) => {
  // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const page1 = foremanApi.getApiUrl('/hosts/1/errata?per_page=20&page=1');
  const page2 = foremanApi.getApiUrl('/hosts/1/errata?page=2&per_page=20');

  // return errata data results when we look for errata
  const scope = nockInstance
    .get(page1)
    .reply(200, makeMockErrata({ page: 1 }));

  const scope2 = nockInstance
    .get(page2)
    .reply(200, makeMockErrata({ page: 2 }));

  const {
    queryByText,
    getAllByText,
    getByLabelText,
    getAllByLabelText,
  } = renderWithRedux(<ErrataTab />, renderOptions);

  // Assert that the errata are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(getAllByText('Important')[0]).toBeInTheDocument());

  getByLabelText('Select row 0').click();
  getByLabelText('Select row 1').click();

  getAllByLabelText('Go to next page')[0].click();
  await patientlyWaitFor(() => expect(getAllByText('Important')[0]).toBeInTheDocument());

  getByLabelText('Select row 0').click();
  getByLabelText('Select row 1').click();

  expect(queryByText('4 selected')).toBeInTheDocument();

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
  assertNockRequest(scope2, done);
});

test('Can select & de-select all errata through selectDropDown', async (done) => {
  // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const mockErrata = makeMockErrata({});
  // return errata data results when we look for errata
  const scope = nockInstance
    .get(hostErrata)
    .reply(200, mockErrata);

  const {
    getByText,
    queryByText,
    getAllByText,
    getByLabelText,
  } = renderWithRedux(<ErrataTab />, renderOptions);

  // Assert that the errata are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(getAllByText('Important')[0]).toBeInTheDocument());

  const selectDropDown = getByLabelText('Select');
  selectDropDown.click();

  const selectAll = getByText(`Select all (${mockErrata.total})`);
  expect(selectAll).toBeInTheDocument();
  selectAll.click();

  expect(queryByText(`${mockErrata.total} selected`)).toBeInTheDocument();
  expect(getByLabelText('Select row 0').checked).toEqual(true);

  selectDropDown.click();
  const selectNone = getByText('Select none (0)');
  selectNone.click();

  expect(queryByText(`${mockErrata.total} selected`)).not.toBeInTheDocument();
  expect(getByLabelText('Select row 0').checked).toEqual(false);

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});

test('Can de-select items in select all mode across pages', async (done) => {
  // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const mockErrata = makeMockErrata({ page: 1 });
  // return errata data results when we look for errata
  const page1 = foremanApi.getApiUrl('/hosts/1/errata?per_page=20&page=1');
  const page2 = foremanApi.getApiUrl('/hosts/1/errata?page=2&per_page=20');
  const page3 = foremanApi.getApiUrl('/hosts/1/errata?page=1&per_page=20');

  // return errata data results when we look for errata
  const scope = nockInstance
    .get(page1)
    .reply(200, mockErrata);

  const scope2 = nockInstance
    .get(page2)
    .reply(200, makeMockErrata({ page: 2 }));

  const scope3 = nockInstance
    .get(page3)
    .reply(200, makeMockErrata({ page: 2 }));

  const {
    queryByText,
    getAllByText,
    getByLabelText,
    getAllByLabelText,
  } = renderWithRedux(<ErrataTab />, renderOptions);

  // Assert that the errata are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(getAllByText('Important')[0]).toBeInTheDocument());

  const selectAllCheckbox = getByLabelText('Select all');
  selectAllCheckbox.click();
  expect(queryByText(`${mockErrata.total} selected`)).toBeInTheDocument();

  expect(getByLabelText('Select row 0').checked).toEqual(true);
  getByLabelText('Select row 0').click(); // de select

  expect(queryByText(`${mockErrata.total - 1} selected`)).toBeInTheDocument();
  expect(getByLabelText('Select row 0').checked).toEqual(false);

  // goto next page
  getAllByLabelText('Go to next page')[0].click();
  await patientlyWaitFor(() => expect(getAllByText('Important')[0]).toBeInTheDocument());

  expect(getByLabelText('Select row 0').checked).toEqual(true);
  getByLabelText('Select row 0').click(); // de select

  expect(queryByText(`${mockErrata.total - 2} selected`)).toBeInTheDocument();
  expect(getByLabelText('Select row 0').checked).toEqual(false);

  // goto previous page
  getAllByLabelText('Go to previous page')[0].click();
  await patientlyWaitFor(() => expect(getAllByText('Important')[0]).toBeInTheDocument());

  expect(getByLabelText('Select row 0').checked).toEqual(false);
  expect(getByLabelText('Select row 1').checked).toEqual(true);
  getByLabelText('Select row 1').click(); // de select

  expect(queryByText(`${mockErrata.total - 3} selected`)).toBeInTheDocument();
  expect(getByLabelText('Select row 1').checked).toEqual(false);

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
  assertNockRequest(scope2, done);
  assertNockRequest(scope3, done);
});

test('Can select page and select only items on the page', async (done) => {
  // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const mockErrata = makeMockErrata({});
  // return errata data results when we look for errata
  const scope = nockInstance
    .get(hostErrata)
    .reply(200, mockErrata);

  const {
    getByText,
    queryByText,
    getAllByText,
    getByLabelText,
  } = renderWithRedux(<ErrataTab />, renderOptions);

  // Assert that the errata are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(getAllByText('Important')[0]).toBeInTheDocument());

  const selectDropDown = getByLabelText('Select');
  selectDropDown.click();

  const selectPage = getByText('Select page (20)');
  expect(selectPage).toBeInTheDocument();
  selectPage.click();

  expect(queryByText('20 selected')).toBeInTheDocument();
  expect(getByLabelText('Select row 0').checked).toEqual(true);

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});

test('Select  disabled if all rows are selected', async (done) => {
  // Setup autocomplete with mockForemanAutoComplete since we aren't adding /katello
  const autocompleteScope = mockForemanAutocomplete(nockInstance, autocompleteUrl);
  const mockErrata = makeMockErrata({});
  // return errata data results when we look for errata
  const scope = nockInstance
    .get(hostErrata)
    .reply(200, mockErrata);

  const {
    getByText,
    queryByText,
    getAllByText,
    getByLabelText,
  } = renderWithRedux(<ErrataTab />, renderOptions);

  // Assert that the errata are now showing on the screen, but wait for them to appear.
  await patientlyWaitFor(() => expect(getAllByText('Important')[0]).toBeInTheDocument());

  const selectDropDown = getByLabelText('Select');
  selectDropDown.click();

  const selectAll = getByText(`Select all (${mockErrata.total})`);
  expect(selectAll).toBeInTheDocument();
  expect(selectAll).toHaveAttribute('aria-disabled', 'false');
  selectAll.click();

  expect(queryByText(`${mockErrata.total} selected`)).toBeInTheDocument();

  // click the dropdown again and  make sure select all is disabled
  selectDropDown.click();
  expect(getByText(`Select all (${mockErrata.total})`)).toHaveAttribute('aria-disabled', 'true');
  expect(getByText('Select page (20)')).toHaveAttribute('aria-disabled', 'true');
  expect(getByText('Select none (0)')).toHaveAttribute('aria-disabled', 'false');

  // Select none
  getByText('Select none (0)').click();
  selectDropDown.click();
  expect(getByText(`Select all (${mockErrata.total})`)).toHaveAttribute('aria-disabled', 'false');
  expect(getByText('Select page (20)')).toHaveAttribute('aria-disabled', 'false');
  expect(getByText('Select none (0)')).toHaveAttribute('aria-disabled', 'true');

  // Select page
  getByText('Select page (20)').click();
  selectDropDown.click();
  expect(getByText(`Select all (${mockErrata.total})`)).toHaveAttribute('aria-disabled', 'false');
  expect(getByText('Select page (20)')).toHaveAttribute('aria-disabled', 'true');
  expect(getByText('Select none (0)')).toHaveAttribute('aria-disabled', 'false');

  assertNockRequest(autocompleteScope);
  assertNockRequest(scope, done); // Pass jest callback to confirm test is done
});

