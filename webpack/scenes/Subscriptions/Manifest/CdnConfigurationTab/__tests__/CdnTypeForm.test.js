import React from 'react';
import { cleanup } from '@testing-library/react';
import { renderWithRedux, fireEvent } from 'react-testing-lib-wrapper';
import CdnTypeForm from '../CdnTypeForm';
import { nockInstance, assertNockRequest } from '../../../../../test-utils/nockWrapper';
import { updateCdnConfigurationSuccessResponse } from '../../../../Organizations/__tests__/organizations.fixtures';
import { CDN, CDN_URL } from '../CdnConfigurationConstants';

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
    showUpdate
    url={CDN_URL}
  />, { initialState });

  const updateCdnConfigurationRequest = nockInstance
    .put(updateCdnConfigurationPath, {
      url: CDN_URL,
      type: CDN,
    })
    .reply(200, updateCdnConfigurationSuccessResponse);

  expect(getByLabelText(updateButtonName)).toHaveAttribute('aria-disabled', 'false');

  const updateButton = getByLabelText(updateButtonName);
  fireEvent.click(updateButton);
  assertNockRequest(updateCdnConfigurationRequest, done);
});

test('Can update the cdn url', async (done) => {
  const { getByLabelText } = renderWithRedux(<CdnTypeForm
    showUpdate={false}
    url={CDN_URL}
  />, { initialState });

  const updateCdnConfigurationRequest = nockInstance
    .put(updateCdnConfigurationPath, {
      url: 'http://cdn.example.com',
      type: CDN,
    })
    .reply(200, updateCdnConfigurationSuccessResponse);

  expect(getByLabelText(updateButtonName)).toHaveAttribute('aria-disabled', 'true');

  const url = getByLabelText('cdn-url');
  fireEvent.change(url, { target: { value: 'http://cdn.example.com' } });

  const updateButton = getByLabelText(updateButtonName);
  expect(updateButton).toHaveAttribute('aria-disabled', 'false');
  fireEvent.click(updateButton);
  assertNockRequest(updateCdnConfigurationRequest, done);
});
