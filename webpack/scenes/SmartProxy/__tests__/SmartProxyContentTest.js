import React from 'react';
import { renderWithRedux, patientlyWaitFor, fireEvent, within, act } from 'react-testing-lib-wrapper';

import { nockInstance, assertNockRequest } from '../../../test-utils/nockWrapper';
import api from '../../../services/api';
import SmartProxyExpandableTable from '../SmartProxyExpandableTable';

const smartProxyContentData = require('./SmartProxyContentTest.fixtures.json');

const smartProxyContentPath = api.getApiUrl('/capsules/1/content/sync');
const smartProxyRefreshCountPath = api.getApiUrl('/capsules/1/content/update_counts');

const smartProxyContent = { ...smartProxyContentData };

const contentTable = <SmartProxyExpandableTable smartProxyId={1} />;

test('Can display Smart proxy content table and expand env and cv details', async (done) => {
  const detailsScope = nockInstance
    .get(smartProxyContentPath)
    .query(true)
    .reply(200, smartProxyContent);

  const {
    getByText, getAllByText, getByLabelText,
  } = renderWithRedux(contentTable);
  await patientlyWaitFor(() => expect(getByText('Environment')).toBeInTheDocument());
  const tdEnvExpand = getByLabelText('expand-env-1');
  const envExpansion = within(tdEnvExpand).getByLabelText('Details');
  envExpansion.click();
  await patientlyWaitFor(() => expect(getAllByText('Content view')[0]).toBeInTheDocument());
  expect(getAllByText('Last published')[0]).toBeInTheDocument();
  expect(getAllByText('Repository')[0]).toBeInTheDocument();
  expect(getAllByText('Synced')[0]).toBeInTheDocument();
  const tdCvExpand = getByLabelText('expand-cv-1');
  const cvExpansion = within(tdCvExpand).getByLabelText('Details');
  expect(cvExpansion).toHaveAttribute('aria-expanded', 'false');
  cvExpansion.click();
  await patientlyWaitFor(() => expect(cvExpansion).toHaveAttribute('aria-expanded', 'true'));
  expect(getByText('Library')).toBeInTheDocument();
  expect(getByText('Default Organization View')).toBeInTheDocument();
  expect(getAllByText('dev')[0]).toBeInTheDocument();
  expect(getAllByText('Repository')[0]).toBeInTheDocument();
  expect(getAllByText('Packages')[0]).toBeInTheDocument();
  expect(getAllByText('Additional content')[0]).toBeInTheDocument();
  expect(getAllByText('repo1')[0]).toBeInTheDocument();
  expect(getAllByText('22 Packages')[0]).toBeInTheDocument();
  expect(getAllByText(/7 errata/i)[0]).toBeInTheDocument();
  expect(getAllByText(/14 Module streams/i)[0]).toBeInTheDocument();
  expect(getAllByText(/2 Package groups/i)[0]).toBeInTheDocument();
  assertNockRequest(detailsScope);
  done();
});

test('Handles empty content_counts and displays N/A for Packages and Additional content', async (done) => {
  const emptyContentCountsData = {
    ...smartProxyContent,
    content_counts: {},
  };

  const detailsScope = nockInstance
    .get(smartProxyContentPath)
    .query(true)
    .reply(200, emptyContentCountsData);

  const { getByText, getAllByText, getByLabelText } = renderWithRedux(contentTable);

  await patientlyWaitFor(() => expect(getByText('Environment')).toBeInTheDocument());

  const tdEnvExpand = getByLabelText('expand-env-1');
  const envExpansion = within(tdEnvExpand).getByLabelText('Details');
  envExpansion.click();

  await patientlyWaitFor(() => expect(getAllByText('Content view')[0]).toBeInTheDocument());
  expect(getAllByText('Last published')[0]).toBeInTheDocument();
  expect(getAllByText('Repository')[0]).toBeInTheDocument();
  expect(getAllByText('Synced')[0]).toBeInTheDocument();

  const tdCvExpand = getByLabelText('expand-cv-1');
  const cvExpansion = within(tdCvExpand).getByLabelText('Details');
  expect(cvExpansion).toHaveAttribute('aria-expanded', 'false');
  cvExpansion.click();

  await patientlyWaitFor(() => expect(cvExpansion).toHaveAttribute('aria-expanded', 'true'));

  expect(getAllByText('N/A')[0]).toBeInTheDocument();
  expect(getAllByText('N/A')[1]).toBeInTheDocument();

  assertNockRequest(detailsScope, done);
});

test('Can call content count refresh for environment', async (done) => {
  const detailsScope = nockInstance
    .get(smartProxyContentPath)
    .query(true)
    .reply(200, smartProxyContent);

  const countsEnvRefreshScope = nockInstance
    .post(smartProxyRefreshCountPath, {
      environment_id: 1,
    })
    .reply(202);

  const {
    getByText, getAllByLabelText,
  } = renderWithRedux(contentTable);
  await patientlyWaitFor(() => expect(getByText('Environment')).toBeInTheDocument());
  expect(getAllByLabelText('Kebab toggle')[0]).toHaveAttribute('aria-expanded', 'false');
  fireEvent.click(getAllByLabelText('Kebab toggle')[0]);
  expect(getAllByLabelText('Kebab toggle')[0]).toHaveAttribute('aria-expanded', 'true');
  await patientlyWaitFor(() => expect(getByText('Refresh counts')).toBeInTheDocument());
  const refreshEnv = getByText('Refresh counts');
  refreshEnv.click();

  assertNockRequest(detailsScope);
  assertNockRequest(countsEnvRefreshScope, done);
  act(done);
});

test('Can call content count refresh for content view', async (done) => {
  const detailsScope = nockInstance
    .get(smartProxyContentPath)
    .query(true)
    .reply(200, smartProxyContent);

  const countsCVRefreshScope = nockInstance
    .post(smartProxyRefreshCountPath, {
      content_view_id: 1,
      environment_id: 1,
    })
    .reply(202);


  const {
    getByText, getAllByText, getByLabelText, getAllByLabelText,
  } = renderWithRedux(contentTable);
  await patientlyWaitFor(() => expect(getByText('Environment')).toBeInTheDocument());
  const tdEnvExpand = getByLabelText('expand-env-1');
  const envExpansion = within(tdEnvExpand).getByLabelText('Details');
  envExpansion.click();
  await patientlyWaitFor(() => expect(getAllByText('Content view')[0]).toBeInTheDocument());
  expect(getAllByText('Last published')[0]).toBeInTheDocument();
  expect(getAllByText('Repository')[0]).toBeInTheDocument();
  expect(getAllByText('Synced')[0]).toBeInTheDocument();
  expect(getAllByLabelText('Kebab toggle')[1]).toHaveAttribute('aria-expanded', 'false');
  fireEvent.click(getAllByLabelText('Kebab toggle')[1]);
  expect(getAllByLabelText('Kebab toggle')[1]).toHaveAttribute('aria-expanded', 'true');

  await patientlyWaitFor(() => expect(getByText('Refresh counts')).toBeInTheDocument());
  const refreshCvCounts = getByText('Refresh counts');
  refreshCvCounts.click();

  assertNockRequest(detailsScope);
  assertNockRequest(countsCVRefreshScope, done);
  act(done);
});
