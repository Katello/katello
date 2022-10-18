import React from 'react';
import { act, renderWithRedux, patientlyWaitFor, fireEvent } from 'react-testing-lib-wrapper';
import { Route } from 'react-router-dom';
import { nockInstance, assertNockRequest } from '../../../../test-utils/nockWrapper';
import api from '../../../../services/api';
import ACSExpandableDetails from '../ACSExpandableDetails';
import acsDetails from './acsDetails.fixtures';

const acsDetailsURL = api.getApiUrl('/alternate_content_sources/1');
const withACSRoute = component => <Route path="/alternate_content_sources/:id([0-9]+)">{component}</Route>;

test('Can call API and show ACS details expandable sections on page load', async (done) => {
  const renderOptions = {
    routerParams: {
      initialEntries: [{ pathname: '/alternate_content_sources/1/details' }],
    },
  };
  const acsDetailsScope = nockInstance
    .get(acsDetailsURL)
    .query(true)
    .reply(200, acsDetails);
  const { queryByText } = renderWithRedux(withACSRoute(<ACSExpandableDetails />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText('test_acs')).toBeNull();
  expect(queryByText('Hide details')).toBeNull();
  expect(queryByText('Show smart proxies')).toBeNull();
  expect(queryByText('Show URL and subpaths')).toBeNull();
  expect(queryByText('Show credentials')).toBeNull();
  // Assert that the ACS name and expandable sections
  // are now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(queryByText('test_acs')).toBeInTheDocument();
    expect(queryByText('Hide details')).toBeInTheDocument();
    expect(queryByText('Show smart proxies')).toBeInTheDocument();
    expect(queryByText('Show URL and subpaths')).toBeInTheDocument();
    expect(queryByText('Show credentials')).toBeInTheDocument();
  });
  assertNockRequest(acsDetailsScope, done);
  act(done);
});

test('Can expand expandable sections on details page', async (done) => {
  const renderOptions = {
    routerParams: {
      initialEntries: [{ pathname: '/alternate_content_sources/1/details' }],
    },
  };
  const acsDetailsScope = nockInstance
    .get(acsDetailsURL)
    .query(true)
    .reply(200, acsDetails);
  const { queryAllByText, queryByText } =
    renderWithRedux(withACSRoute(<ACSExpandableDetails />), renderOptions);

  // Nothing will show at first, page is loading
  expect(queryByText('test_acs')).toBeNull();
  // Assert that the ACS name and expandable sections
  // are now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(queryByText('test_acs')).toBeInTheDocument();
    expect(queryByText('Hide details')).toBeInTheDocument();
    expect(queryByText('Show smart proxies')).toBeInTheDocument();
    expect(queryByText('Show URL and subpaths')).toBeInTheDocument();
    expect(queryByText('Show credentials')).toBeInTheDocument();
  });
  const showSmartProxyButton = queryByText('Show smart proxies');
  fireEvent.click(showSmartProxyButton);
  await patientlyWaitFor(() => {
    expect(queryByText('test_acs')).toBeInTheDocument();
    expect(queryByText('Show details')).toBeInTheDocument();
    expect(queryByText('Hide smart proxies')).toBeInTheDocument();
    expect(queryByText('centos7-katello-devel-stable.example.com')).toBeInTheDocument();
    expect(queryByText('Show URL and subpaths')).toBeInTheDocument();
    expect(queryByText('Show credentials')).toBeInTheDocument();
  });

  const showURLSubpathsButton = queryByText('Show URL and subpaths');
  fireEvent.click(showURLSubpathsButton);
  await patientlyWaitFor(() => {
    expect(queryByText('test_acs')).toBeInTheDocument();
    expect(queryByText('Show details')).toBeInTheDocument();
    expect(queryByText('Show smart proxies')).toBeInTheDocument();
    expect(queryByText('Hide URL and subpaths')).toBeInTheDocument();
    expect(queryByText('https://fedorapeople.org/groups/katello/fakerepos/')).toBeInTheDocument();
    expect(queryByText('zoo/, zoo2/, zoo3/, zoo4/, zoo5/')).toBeInTheDocument();
    expect(queryByText('Show credentials')).toBeInTheDocument();
  });

  const showCredentialButton = queryByText('Show credentials');
  fireEvent.click(showCredentialButton);
  await patientlyWaitFor(() => {
    expect(queryByText('test_acs')).toBeInTheDocument();
    expect(queryByText('Show details')).toBeInTheDocument();
    expect(queryByText('Show smart proxies')).toBeInTheDocument();
    expect(queryByText('Show URL and subpaths')).toBeInTheDocument();
    expect(queryByText('Hide credentials')).toBeInTheDocument();
    expect(queryByText('Verify SSL')).toBeInTheDocument();
    expect(queryByText('false')).toBeInTheDocument();
    expect(queryByText('SSL CA certificate')).toBeInTheDocument();
    expect(queryAllByText('N/A')[0]).toBeInTheDocument();
  });

  assertNockRequest(acsDetailsScope, done);
  act(done);
});
