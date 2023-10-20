import React from 'react';
import { renderWithRedux, patientlyWaitFor, within } from 'react-testing-lib-wrapper';

import { nockInstance, assertNockRequest } from '../../../test-utils/nockWrapper';
import api from '../../../services/api';
import SmartProxyExpandableTable from '../SmartProxyExpandableTable';

const smartProxyContentData = require('./SmartProxyContent.fixtures.json');

const smartProxyContentPath = api.getApiUrl('/capsules/1/content/sync');

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
  assertNockRequest(detailsScope, done);
});
