import React from 'react';
import { cleanup } from '@testing-library/react';
import { renderWithRedux, fireEvent, patientlyWaitFor } from 'react-testing-lib-wrapper';
import userEvent from '@testing-library/user-event';
import NetworkSyncForm from '../NetworkSyncForm';
import { nockInstance, assertNockRequest } from '../../../../../test-utils/nockWrapper';
import { updateCdnConfigurationSuccessResponse } from '../../../../Organizations/__tests__/organizations.fixtures';
import { NETWORK_SYNC } from '../CdnConfigurationConstants';

import api from '../../../../../services/api';

afterEach(cleanup);
const updateCdnConfigurationPath = api.getApiUrl('/organizations/1/cdn_configuration');

const updateButtonName = 'update-upstream-configuration';

const cdnConfiguration = {
  url: 'http://currentcdn.example.com',
  username: 'CurrentUser',
  password_exists: false,
  upstream_organization_label: 'CurrentOrg',
  ssl_ca_credential_id: 2,
  type: NETWORK_SYNC,
  upstream_lifecycle_environment_label: 'Library',
  upstream_content_view_label: 'CV',
};

const organization = {
  id: 1,
};

const initialState = {
  katello: {
    organization,
  },
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

test('Can update the upstream server configuration', async (done) => {
  const { getByLabelText } = renderWithRedux(<NetworkSyncForm
    typeChangeInProgress
    cdnConfiguration={cdnConfiguration}
    contentCredentials={contentCredentials}
  />, { initialState });

  const updateCdnConfigurationRequest = nockInstance
    .put(updateCdnConfigurationPath, {
      url: 'http://cdn.example.com',
      username: 'admin',
      password: 'changeme',
      upstream_organization_label: 'Default_Organization',
      ssl_ca_credential_id: '1',
      type: NETWORK_SYNC,
      upstream_lifecycle_environment_label: 'Library',
      upstream_content_view_label: 'CV',
    })
    .reply(200, updateCdnConfigurationSuccessResponse);

  const url = getByLabelText('cdn-url');
  fireEvent.change(url, { target: { value: 'http://cdn.example.com' } });

  const username = getByLabelText('cdn-username');
  fireEvent.change(username, { target: { value: 'admin' } });

  fireEvent.click(getByLabelText('edit cdn-password'));
  fireEvent.change(getByLabelText('cdn-password text input'), { target: { value: 'changeme' } });
  fireEvent.click(getByLabelText('submit cdn-password'));
  await patientlyWaitFor(() => expect(getByLabelText('cdn-password text value')).toBeInTheDocument());

  const orgLabel = getByLabelText('cdn-organization-label');
  fireEvent.change(orgLabel, { target: { value: 'Default_Organization' } });

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
  const { getAllByTestId, getByLabelText } = renderWithRedux(<NetworkSyncForm
    typeChangeInProgress
    cdnConfiguration={cdnConfiguration}
    contentCredentials={contentCredentials}
  />, { initialState });

  const username = getByLabelText('cdn-username');
  expect(username).toHaveValue('CurrentUser');

  const options = getAllByTestId('ssl-ca-content-credential-option');

  expect(options).toHaveLength(contentCredentials.length);
  expect(options[0].selected).toBeFalsy();
  expect(options[1].selected).toBeTruthy();
});

test('resetting the password enables/disables appropriately', async (done) => {
  const { getByLabelText } = renderWithRedux(<NetworkSyncForm
    typeChangeInProgress
    cdnConfiguration={{ ...cdnConfiguration, password_exists: true }}
  />, { initialState });

  expect(getByLabelText(updateButtonName)).toHaveAttribute('aria-disabled', 'true');
  fireEvent.click(getByLabelText('edit cdn-password'));
  fireEvent.change(getByLabelText('cdn-password text input'), { target: { value: 'changeme' } });
  fireEvent.click(getByLabelText('clear cdn-password'));
  expect(getByLabelText(updateButtonName)).toHaveAttribute('aria-disabled', 'true');

  fireEvent.click(getByLabelText('edit cdn-password'));
  fireEvent.change(getByLabelText('cdn-password text input'), { target: { value: 'changeme' } });
  fireEvent.click(getByLabelText('submit cdn-password'));

  await patientlyWaitFor(() => expect(getByLabelText('cdn-password text value')).toBeInTheDocument());
  expect(getByLabelText(updateButtonName)).toHaveAttribute('aria-disabled', 'false');
  done();
});

test('update button disabled on incomplete information', async (done) => {
  const { getByLabelText } = renderWithRedux(<NetworkSyncForm
    typeChangeInProgress
    cdnConfiguration={{ ...cdnConfiguration, password_exists: true }}
    contentCredentials={contentCredentials}
  />, { initialState });

  expect(getByLabelText(updateButtonName)).toHaveAttribute('aria-disabled', 'true');
  fireEvent.change(getByLabelText('cdn-username'), { target: { value: 'user' } });
  expect(getByLabelText(updateButtonName)).toHaveAttribute('aria-disabled', 'false');
  done();
});
