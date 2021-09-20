import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import nock, { nockInstance, assertNockRequest, mockForemanAutocomplete, mockSetting } from '../../../../../test-utils/nockWrapper';
import { foremanApi } from '../../../../../services/api';
import { HOST_ERRATA_KEY } from '../../HostErrata/HostErrataConstants';
import { ErrataTab } from '../ErrataTab';

const mockErrataData = require('./errata.fixtures.json');

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

const hostErrata = foremanApi.getApiUrl('/hosts/1/errata?per_page=20&page=1');
const autocompleteUrl = '/hosts/1/errata/auto_complete_search';

let firstErrata;
let searchDelayScope;
let autoSearchScope;

beforeEach(() => {
  const { results } = mockErrataData;
  [firstErrata] = results;
  searchDelayScope = mockSetting(nockInstance, 'autosearch_delay', 500);
  autoSearchScope = mockSetting(nockInstance, 'autosearch_while_typing', true);
});

afterEach(() => {
  nock.cleanAll();
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
