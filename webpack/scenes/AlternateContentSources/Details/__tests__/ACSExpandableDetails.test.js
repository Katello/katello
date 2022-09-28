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
  expect(queryByText('Details')).toBeNull();
  expect(queryByText('Smart proxies')).toBeNull();
  expect(queryByText('URL and subpaths')).toBeNull();
  expect(queryByText('Credentials')).toBeNull();
  // Assert that the ACS name and expandable sections
  // are now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(queryByText('test_acs')).toBeInTheDocument();
    expect(queryByText('Details')).toBeInTheDocument();
    expect(queryByText('Smart proxies')).toBeInTheDocument();
    expect(queryByText('URL and subpaths')).toBeInTheDocument();
    expect(queryByText('Credentials')).toBeInTheDocument();
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
    expect(queryByText('Details')).toBeInTheDocument();
    expect(queryByText('Smart proxies')).toBeInTheDocument();
    expect(queryByText('URL and subpaths')).toBeInTheDocument();
    expect(queryByText('Credentials')).toBeInTheDocument();
  });
  const showSmartProxyButton = queryByText('Smart proxies');
  fireEvent.click(showSmartProxyButton);
  await patientlyWaitFor(() => {
    expect(queryByText('test_acs')).toBeInTheDocument();
    expect(queryByText('Details')).toBeInTheDocument();
    expect(queryByText('Smart proxies')).toBeInTheDocument();
    expect(queryByText('centos7-katello-devel-stable.example.com')).toBeInTheDocument();
    expect(queryByText('URL and subpaths')).toBeInTheDocument();
    expect(queryByText('Credentials')).toBeInTheDocument();
  });

  const showURLSubpathsButton = queryByText('URL and subpaths');
  fireEvent.click(showURLSubpathsButton);
  await patientlyWaitFor(() => {
    expect(queryByText('test_acs')).toBeInTheDocument();
    expect(queryByText('Details')).toBeInTheDocument();
    expect(queryByText('Smart proxies')).toBeInTheDocument();
    expect(queryByText('URL and subpaths')).toBeInTheDocument();
    expect(queryByText('https://fedorapeople.org/groups/katello/fakerepos/')).toBeInTheDocument();
    expect(queryByText('zoo/, zoo2/, zoo3/, zoo4/, zoo5/')).toBeInTheDocument();
    expect(queryByText('Credentials')).toBeInTheDocument();
  });

  const showCredentialButton = queryByText('Credentials');
  fireEvent.click(showCredentialButton);
  await patientlyWaitFor(() => {
    expect(queryByText('test_acs')).toBeInTheDocument();
    expect(queryByText('Details')).toBeInTheDocument();
    expect(queryByText('Smart proxies')).toBeInTheDocument();
    expect(queryByText('URL and subpaths')).toBeInTheDocument();
    expect(queryByText('Credentials')).toBeInTheDocument();
    expect(queryByText('Verify SSL')).toBeInTheDocument();
    expect(queryByText('false')).toBeInTheDocument();
    expect(queryByText('SSL CA certificate')).toBeInTheDocument();
    expect(queryAllByText('N/A')[0]).toBeInTheDocument();
  });

  assertNockRequest(acsDetailsScope, done);
  act(done);
});
