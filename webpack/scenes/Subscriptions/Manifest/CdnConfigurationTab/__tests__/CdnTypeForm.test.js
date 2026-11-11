import React from 'react';
import { connect } from 'react-redux';
import { cleanup } from '@testing-library/react';
import { renderWithRedux, fireEvent, patientlyWaitFor, within } from 'react-testing-lib-wrapper';
import { STATUS } from 'foremanReact/constants';
import CdnTypeForm from '../CdnTypeForm';
import CdnConfigurationForm from '../index';
import { nockInstance } from '../../../../../test-utils/nockWrapper';
import { updateCdnConfigurationSuccessResponse } from '../../../../Organizations/__tests__/organizations.fixtures';
import { UPDATE_CDN_CONFIGURATION_KEY } from '../../../../Organizations/OrganizationConstants';
import { loadOrganization } from '../../../../Organizations/OrganizationActions';
import { CDN, CDN_URLS, DEFAULT_CDN_URL } from '../CdnConfigurationConstants';

import api from '../../../../../services/api';

afterEach(cleanup);
const updateCdnConfigurationPath = api.getApiUrl('/organizations/1/cdn_configuration');

const updateButtonName = 'update-cdn-configuration';
const cdnUrlLabel = 'redhat-cdn-url';
const organization = {
  id: 1,
};

const initialState = {
  katello: {
    organization,
  },
};

const ConnectedCdnConfigurationForm = connect(
  state => ({ cdnConfiguration: state.katello.organization.cdn_configuration }),
  dispatch => ({ onUpdate: () => dispatch(loadOrganization()) }),
)(CdnConfigurationForm);

test('Can update to cdn type with the default URL', async () => {
  const onUpdate = jest.fn();
  const { getByLabelText } = renderWithRedux(<CdnTypeForm
    typeChangeInProgress
    cdnConfiguration={{ url: DEFAULT_CDN_URL }}
    onUpdate={onUpdate}
  />, { initialState });

  const updateCdnConfigurationRequest = nockInstance
    .put(updateCdnConfigurationPath, {
      type: CDN,
      url: DEFAULT_CDN_URL,
    })
    .reply(200, updateCdnConfigurationSuccessResponse);

  expect(getByLabelText(updateButtonName)).toHaveAttribute('aria-disabled', 'false');
  expect(getByLabelText(cdnUrlLabel)).not.toHaveAttribute('disabled');
  expect(getByLabelText(cdnUrlLabel)).toHaveValue(DEFAULT_CDN_URL);

  const updateButton = getByLabelText(updateButtonName);
  fireEvent.click(updateButton);
  await patientlyWaitFor(() => expect(onUpdate).toHaveBeenCalledTimes(1));
  updateCdnConfigurationRequest.done();
});

test('Can select and save a sovereign endpoint without changing the CDN type', async () => {
  const url = 'https://cdn-eu.redhat.com';
  const onUpdate = jest.fn();
  const { getByLabelText } = renderWithRedux(<CdnTypeForm
    typeChangeInProgress={false}
    cdnConfiguration={{ type: CDN, url: DEFAULT_CDN_URL }}
    onUpdate={onUpdate}
  />, { initialState });

  const updateButton = getByLabelText(updateButtonName);
  const dropdown = getByLabelText(cdnUrlLabel);
  expect(updateButton).toHaveAttribute('aria-disabled', 'true');

  fireEvent.change(dropdown, { target: { value: url } });

  expect(dropdown).toHaveValue(url);
  expect(updateButton).toHaveAttribute('aria-disabled', 'false');

  const updateCdnConfigurationRequest = nockInstance
    .put(updateCdnConfigurationPath, { type: CDN, url })
    .reply(200, updateCdnConfigurationSuccessResponse);

  fireEvent.click(updateButton);

  await patientlyWaitFor(() => expect(onUpdate).toHaveBeenCalledTimes(1));
  updateCdnConfigurationRequest.done();
});

test('Offers the endpoints reported by the API alongside the saved one', () => {
  const url = 'https://cdn-apac.redhat.com';
  const { getByLabelText } = renderWithRedux(<CdnTypeForm
    typeChangeInProgress={false}
    cdnConfiguration={{ type: CDN, url, cdn_urls: CDN_URLS }}
  />, { initialState });

  const dropdown = getByLabelText(cdnUrlLabel);
  expect(dropdown).toHaveValue(url);
  expect(within(dropdown).getAllByRole('option').map(option => option.value))
    .toEqual([...CDN_URLS, url]);
  expect(getByLabelText(updateButtonName)).toHaveAttribute('aria-disabled', 'true');
});

test('Follows the saved endpoint when the organization reloads', async () => {
  const url = 'https://cdn-eu.redhat.com';
  const savedOrganization = {
    ...organization,
    cdn_configuration: { type: CDN, url: DEFAULT_CDN_URL },
  };
  const reloadRequest = nockInstance
    .get(api.getApiUrl('/organizations/1'))
    .reply(200, { ...savedOrganization, cdn_configuration: { type: CDN, url } });
  const { getByLabelText, store } = renderWithRedux(<ConnectedCdnConfigurationForm />, {
    initialState: { katello: { organization: savedOrganization } },
  });

  store.dispatch(loadOrganization());

  await patientlyWaitFor(() => expect(getByLabelText(cdnUrlLabel)).toHaveValue(url));
  expect(getByLabelText(updateButtonName)).toHaveAttribute('aria-disabled', 'true');
  reloadRequest.done();
});

test('Keeps type switches disabled until saving and reloading the endpoint finish', async () => {
  const url = 'https://cdn-eu.redhat.com';
  const savedOrganization = {
    ...organization,
    cdn_configuration: { type: CDN, url: DEFAULT_CDN_URL },
  };
  let finishUpdate;
  let finishReload;
  const updateRequest = nockInstance
    .put(updateCdnConfigurationPath, { type: CDN, url })
    .reply(() => new Promise((resolve) => { finishUpdate = resolve; }));
  const reloadRequest = nockInstance
    .get(api.getApiUrl('/organizations/1'))
    .reply(() => new Promise((resolve) => { finishReload = resolve; }));
  const { getByLabelText, getByRole, store } = renderWithRedux(
    <ConnectedCdnConfigurationForm />,
    { initialState: { katello: { organization: savedOrganization } } },
  );
  const typeButtons = within(getByRole('group', {
    name: 'Default with multiple selectable',
  })).getAllByRole('button');

  typeButtons.forEach(button => expect(button).not.toBeDisabled());
  fireEvent.change(getByLabelText(cdnUrlLabel), { target: { value: url } });
  fireEvent.click(getByLabelText(updateButtonName));

  await patientlyWaitFor(() => expect(finishUpdate).toBeDefined());
  typeButtons.forEach((button) => {
    expect(button).toBeDisabled();
    fireEvent.click(button);
  });
  expect(getByLabelText(cdnUrlLabel)).toHaveValue(url);

  finishUpdate([200, updateCdnConfigurationSuccessResponse]);
  await patientlyWaitFor(() => {
    expect(finishReload).toBeDefined();
    expect(store.getState().API[UPDATE_CDN_CONFIGURATION_KEY].status).toBe(STATUS.RESOLVED);
  });
  typeButtons.forEach((button) => {
    expect(button).toBeDisabled();
    fireEvent.click(button);
  });
  expect(getByLabelText(cdnUrlLabel)).toHaveValue(url);

  finishReload([200, {
    ...savedOrganization,
    cdn_configuration: { type: CDN, url },
  }]);
  await patientlyWaitFor(() => {
    typeButtons.forEach(button => expect(button).not.toBeDisabled());
    expect(getByLabelText(cdnUrlLabel)).toHaveValue(url);
    expect(getByLabelText(updateButtonName)).toHaveAttribute('aria-disabled', 'true');
  });
  updateRequest.done();
  reloadRequest.done();
});

test('Preserves a configured CDN default outside the standard endpoints', () => {
  const defaultUrl = 'https://mirror.example.com';
  const { getByLabelText } = renderWithRedux(<CdnConfigurationForm
    cdnConfiguration={{ type: CDN, url: defaultUrl, default_url: defaultUrl }}
  />, { initialState });

  const dropdown = getByLabelText(cdnUrlLabel);
  const updateButton = getByLabelText(updateButtonName);
  expect(dropdown).toHaveValue(defaultUrl);
  expect(updateButton).toHaveAttribute('aria-disabled', 'true');

  fireEvent.change(dropdown, { target: { value: 'https://cdn-eu.redhat.com' } });
  expect(updateButton).toHaveAttribute('aria-disabled', 'false');

  fireEvent.change(dropdown, { target: { value: defaultUrl } });
  expect(dropdown).toHaveValue(defaultUrl);
  expect(updateButton).toHaveAttribute('aria-disabled', 'true');
});

test('Can select and save the configured default from a sovereign endpoint', async () => {
  const defaultUrl = 'https://mirror.example.com';
  const onUpdate = jest.fn();
  const { getByLabelText } = renderWithRedux(<CdnConfigurationForm
    cdnConfiguration={{ type: CDN, url: 'https://cdn-eu.redhat.com', default_url: defaultUrl }}
    onUpdate={onUpdate}
  />, { initialState });

  const updateCdnConfigurationRequest = nockInstance
    .put(updateCdnConfigurationPath, { type: CDN, url: defaultUrl })
    .reply(200, updateCdnConfigurationSuccessResponse);

  fireEvent.change(getByLabelText(cdnUrlLabel), { target: { value: defaultUrl } });
  expect(getByLabelText(cdnUrlLabel)).toHaveValue(defaultUrl);
  expect(getByLabelText(updateButtonName)).toHaveAttribute('aria-disabled', 'false');
  fireEvent.click(getByLabelText(updateButtonName));

  await patientlyWaitFor(() => expect(onUpdate).toHaveBeenCalledTimes(1));
  updateCdnConfigurationRequest.done();
});

test('Uses the configured CDN default when switching from an unrelated upstream URL', () => {
  const defaultUrl = 'https://mirror.example.com';
  const { getByLabelText, queryByRole } = renderWithRedux(<CdnTypeForm
    typeChangeInProgress
    cdnConfiguration={{ url: 'https://upstream.example.com', default_url: defaultUrl }}
  />, { initialState });

  expect(getByLabelText(cdnUrlLabel)).toHaveValue(defaultUrl);
  expect(getByLabelText(updateButtonName)).toHaveAttribute('aria-disabled', 'false');
  expect(queryByRole('option', { name: 'https://upstream.example.com' })).not.toBeInTheDocument();
});

test.each([
  ['loading the organization', {
    initialState: { katello: { organization: { ...organization, loading: true } } },
  }],
  ['saving the configuration', {
    initialState,
    apiNamespace: UPDATE_CDN_CONFIGURATION_KEY,
    initialApiState: { status: STATUS.PENDING },
  }],
])('Disables the dropdown and Update while %s', (_description, renderOptions) => {
  const { getByLabelText } = renderWithRedux(<CdnTypeForm
    typeChangeInProgress
    cdnConfiguration={{ type: CDN, url: DEFAULT_CDN_URL }}
  />, renderOptions);

  expect(getByLabelText(cdnUrlLabel)).toHaveAttribute('disabled');
  expect(getByLabelText(updateButtonName)).toHaveAttribute('aria-disabled', 'true');
});
