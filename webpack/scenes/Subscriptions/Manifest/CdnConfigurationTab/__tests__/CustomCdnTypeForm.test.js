import React from 'react';
import { cleanup } from '@testing-library/react';
import { renderWithRedux, fireEvent } from 'react-testing-lib-wrapper';
import userEvent from '@testing-library/user-event';
import CustomCdnTypeForm from '../CustomCdnTypeForm';
import { nockInstance, assertNockRequest } from '../../../../../test-utils/nockWrapper';
import { updateCdnConfigurationSuccessResponse } from '../../../../Organizations/__tests__/organizations.fixtures';
import { CUSTOM_CDN } from '../CdnConfigurationConstants';

import api from '../../../../../services/api';

afterEach(cleanup);
const updateCdnConfigurationPath = api.getApiUrl('/organizations/1/cdn_configuration');

const updateButtonName = 'update-custom-cdn-configuration';
const organization = {
  id: 1,
};

const initialState = {
  katello: {
    organization,
  },
};

const cdnConfiguration = {
  url: 'http://currentcdn.example.com',
  ssl_ca_credential_id: 2,
  type: CUSTOM_CDN,
};

const contentCredentials = [
  {
    name: 'Credential1',
    id: 1,
  },
  {
    name: 'Credential2',
    id: 2,
  },
];

test('Can update the custom cdn server configuration', async (done) => {
  const { getByLabelText } = renderWithRedux(<CustomCdnTypeForm
    typeChangeInProgress
    cdnConfiguration={cdnConfiguration}
    contentCredentials={contentCredentials}
  />, { initialState });

  const updateCdnConfigurationRequest = nockInstance
    .put(updateCdnConfigurationPath, {
      url: 'http://cdn.example.com',
      ssl_ca_credential_id: '1',
      type: CUSTOM_CDN,
    })
    .reply(200, updateCdnConfigurationSuccessResponse);

  const url = getByLabelText('cdn-url');
  fireEvent.change(url, { target: { value: 'http://cdn.example.com' } });

  userEvent.selectOptions(
    getByLabelText('cdn-ssl-ca-content-credential'),
    '1',
  );

  const updateButton = getByLabelText(updateButtonName);
  fireEvent.click(updateButton);

  assertNockRequest(updateCdnConfigurationRequest);
  done();
});

test('the form shall reflect the given cdnConfiguration', () => {
  const { getAllByTestId } = renderWithRedux(<CustomCdnTypeForm
    typeChangeInProgress
    cdnConfiguration={cdnConfiguration}
    contentCredentials={contentCredentials}
  />, { initialState });

  const options = getAllByTestId('ssl-ca-content-credential-option');

  expect(options).toHaveLength(contentCredentials.length);
  expect(options[0].selected).toBeFalsy();
  expect(options[1].selected).toBeTruthy();
});

test('update button disabled on incomplete information', async (done) => {
  const { getByLabelText } = renderWithRedux(<CustomCdnTypeForm
    typeChangeInProgress
    cdnConfiguration={{ ...cdnConfiguration, url: '' }}
    contentCredentials={contentCredentials}
  />, { initialState });

  expect(getByLabelText(updateButtonName)).toHaveAttribute('aria-disabled', 'true');
  fireEvent.change(getByLabelText('cdn-url'), { target: { value: 'http://example.com' } });
  expect(getByLabelText(updateButtonName)).toHaveAttribute('aria-disabled', 'false');
  done();
});
