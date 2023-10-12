import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';

import { nockInstance, assertNockRequest } from '../../../test-utils/nockWrapper';
import api from '../../../services/api';
import SmartProxyExpandableTable from '../SmartProxyExpandableTable';

const smartProxyContentData = require('./SmartProxyContentResult.fixtures.json');

const smartProxyContentPath = api.getApiUrl('/capsules/1/content/sync');

const smartProxyContent = { ...smartProxyContentData };

const contentTable = <SmartProxyExpandableTable smartProxyId={1} />;

test('Can display Smart proxy content table', async (done) => {
  const detailsScope = nockInstance
    .get(smartProxyContentPath)
    .query(true)
    .reply(200, smartProxyContent);

  const { getByText, getAllByText, getAllByLabelText } = renderWithRedux(contentTable);
  await patientlyWaitFor(() => expect(getByText('Environment')).toBeInTheDocument());
  expect(getAllByText('Content view')[0]).toBeInTheDocument();
  expect(getAllByText('Last published')[0]).toBeInTheDocument();
  expect(getAllByText('Repository')[0]).toBeInTheDocument();
  expect(getAllByText('Synced')[0]).toBeInTheDocument();
  expect(getAllByLabelText('Details')[0]).toHaveAttribute('aria-expanded', 'false');
  getAllByLabelText('Details')[0].click();
  expect(getAllByLabelText('Details')[0]).toHaveAttribute('aria-expanded', 'true');
  expect(getByText('Library')).toBeInTheDocument();
  expect(getByText('Default Organization View')).toBeInTheDocument();
  expect(getByText('dev')).toBeInTheDocument();


  assertNockRequest(detailsScope, done);
});
