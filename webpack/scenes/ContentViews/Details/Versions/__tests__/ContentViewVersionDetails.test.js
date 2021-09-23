import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest } from '../../../../../test-utils/nockWrapper';
import api from '../../../../../services/api';
import { cvVersionDetailsKey } from '../../../ContentViewsConstants';
import ContentViewVersionDetails from '../ContentViewVersionDetails';

const ContentViewVersionDetailsData = require('./ContentViewVersionDetails.fixtures.json');

const cvVersions = api.getApiUrl('/content_view_versions/41');

const renderOptions = {
  apiNamespace: cvVersionDetailsKey(19, 41),
  routerParams: {
    initialEntries: [{ hash: '#versions?subContentId=41', pathname: '/content_views/19' }],
    initialIndex: 1,
  },
};

test('Can show versions detail header', async (done) => {
  const { version } = ContentViewVersionDetailsData;
  const scope = nockInstance
    .get(cvVersions)
    .query(true)
    .reply(200, ContentViewVersionDetailsData);

  const { getByText, queryByText } = renderWithRedux(
    <ContentViewVersionDetails />,
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
