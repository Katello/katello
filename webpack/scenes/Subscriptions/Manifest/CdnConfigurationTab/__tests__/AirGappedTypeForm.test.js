import React from 'react';
import { cleanup } from '@testing-library/react';
import { renderWithRedux, fireEvent } from 'react-testing-lib-wrapper';
import AirGappedTypeForm from '../AirGappedTypeForm';
import { nockInstance, assertNockRequest } from '../../../../../test-utils/nockWrapper';
import { updateCdnConfigurationSuccessResponse } from '../../../../Organizations/__tests__/organizations.fixtures';
import { AIRGAPPED } from '../CdnConfigurationConstants';

import api from '../../../../../services/api';

afterEach(cleanup);
const updateCdnConfigurationPath = api.getApiUrl('/organizations/1/cdn_configuration');

const updateButtonName = 'update-airgapped-configuration';

const organization = {
  id: 1,
};

const initialState = {
  katello: {
    organization,
  },
};


test('Can update to Airgapped type', async (done) => {
  const { getByLabelText } = renderWithRedux(<AirGappedTypeForm
    showUpdate
  />, { initialState });

  const updateCdnConfigurationRequest = nockInstance
    .put(updateCdnConfigurationPath, {
      type: AIRGAPPED,
    })
    .reply(200, updateCdnConfigurationSuccessResponse);

  expect(getByLabelText(updateButtonName)).toHaveAttribute('aria-disabled', 'false');

  const updateButton = getByLabelText(updateButtonName);
  fireEvent.click(updateButton);
  assertNockRequest(updateCdnConfigurationRequest, done);
});

