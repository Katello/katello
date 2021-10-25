import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import { Route } from 'react-router-dom';

import { nockInstance, assertNockRequest } from '../../../../../../test-utils/nockWrapper';
import api from '../../../../../../services/api';
import { cvVersionDetailsKey } from '../../../../ContentViewsConstants';
import ContentViewVersionDetails from '../ContentViewVersionDetails';

const ContentViewVersionDetailsEmptyData = require('./ContentViewVersionDetails.fixtures.json');
const cvDetailData = require('../../../../__tests__/mockDetails.fixtures.json');

const withCVRoute = component =>
  <Route path="/versions/:versionId([0-9]+)">{component}</Route>;
const cvVersions = api.getApiUrl('/content_view_versions/73');

const renderOptions = {
  apiNamespace: cvVersionDetailsKey(3, 73),
  routerParams: {
    initialEntries: [{ pathname: '/versions/73' }],
    initialIndex: 1,
  },
};

test('Can show versions detail header', async (done) => {
  const { version } = ContentViewVersionDetailsEmptyData;
  const scope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, ContentViewVersionDetailsEmptyData);

  const { getByText, queryByText } = renderWithRedux(
    withCVRoute(<ContentViewVersionDetails cvId={3} details={cvDetailData} />),
    renderOptions,
  );

  // Nothing will show at first, page is loading
  expect(queryByText(`Version ${version}`)).toBeNull();
  // Assert that the CV version is now showing on the screen, but wait for it to appear.
  await patientlyWaitFor(() => {
    expect(getByText(`Version ${version}`)).toBeTruthy();
  });

  assertNockRequest(scope, done);
});
