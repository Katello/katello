import React from 'react';
import { cleanup } from '@testing-library/react';
import { renderWithRedux, fireEvent } from 'react-testing-lib-wrapper';
import CdnTypeForm from '../CdnTypeForm';
import { nockInstance, assertNockRequest } from '../../../../../test-utils/nockWrapper';
import { updateCdnConfigurationSuccessResponse } from '../../../../Organizations/__tests__/organizations.fixtures';
import { CDN } from '../CdnConfigurationConstants';

import api from '../../../../../services/api';

afterEach(cleanup);
const updateCdnConfigurationPath = api.getApiUrl('/organizations/1/cdn_configuration');

const updateButtonName = 'update-cdn-configuration';
const organization = {
  id: 1,
};

const initialState = {
  katello: {
    organization,
  },
};

test('Can update to cdn type', async (done) => {
  const { getByLabelText } = renderWithRedux(<CdnTypeForm
    typeChangeInProgress
  />, { initialState });

  const updateCdnConfigurationRequest = nockInstance
    .put(updateCdnConfigurationPath, {
      type: CDN,
    })
    .reply(200, updateCdnConfigurationSuccessResponse);

  expect(getByLabelText(updateButtonName)).toHaveAttribute('aria-disabled', 'false');
  expect(getByLabelText('redhat-cdn-url')).toHaveAttribute('disabled');

  const updateButton = getByLabelText(updateButtonName);
  fireEvent.click(updateButton);
  assertNockRequest(updateCdnConfigurationRequest);
  done();
});
