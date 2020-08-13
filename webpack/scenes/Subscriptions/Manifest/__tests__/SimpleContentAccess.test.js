import React from 'react';
import { cleanup } from '@testing-library/react';
import { renderWithRedux, fireEvent, patientlyWaitFor } from 'react-testing-lib-wrapper';
import ManifestModal from '../../Manifest';
import { manifestHistorySuccessState, manifestHistorySuccessResponse } from './manifest.fixtures';
import { nockInstance, assertNockRequest } from '../../../../test-utils/nockWrapper';
import api from '../../../../services/api';

afterEach(cleanup);

const noop = jest.fn();
const organization = { id: 1, redhat_repository_url: 'https://redhat.com' };

const defaultProps = {
  disableManifestActions: false,
  disabledReason: '',
  canImportManifest: true,
  canDeleteManifest: true,
  canEditOrganizations: true,
  upload: noop,
  refresh: noop,
  delete: noop,
  enableSimpleContentAccess: noop,
  disableSimpleContentAccess: noop,
  loadManifestHistory: noop,
  organization,
  loadOrganization: noop,
  saveOrganization: noop,
  taskInProgress: false,
  simpleContentAccess: true,
  manifestHistory: manifestHistorySuccessState,
  setModalClosed: noop,
  setModalOpen: noop,
};

const initialState = {
  katello: {
    organization: {
      simple_content_access: false,
      ...organization,
    },
  },
  foremanModals: {
    manageManifestModal: {
      isOpen: true,
    },
  },
};

const enableSimpleContetAccessPath = api.getApiUrl('/organizations/1/upstream_subscriptions/simple_content_access/enable');
const disableSimpleContetAccessPath = api.getApiUrl('/organizations/1/upstream_subscriptions/simple_content_access/disable');
const manifestHistoryPath = api.getApiUrl('/organizations/1/subscriptions/manifest_history');

test('Enable Simple Content Access after toggle switch value to true', async (done) => {
  const { getByTestId } = renderWithRedux(<ManifestModal {...defaultProps} />, { initialState });

  const updatescope = nockInstance
    .put(enableSimpleContetAccessPath)
    .reply(202, true);

  const getscope = nockInstance
    .get(manifestHistoryPath)
    .query(true)
    .reply(200, manifestHistorySuccessResponse);

  const toggleButton = getByTestId('switch');

  await patientlyWaitFor(() => { expect(toggleButton).toBeInTheDocument(); });
  expect(toggleButton.checked).toEqual(false);

  fireEvent.click(toggleButton);

  assertNockRequest(getscope);
  assertNockRequest(updatescope, done);
});

test('Disable Simple Content Access after toggle switch value to false', async (done) => {
  initialState.katello.organization.simple_content_access = true;

  const updatescope = nockInstance
    .put(disableSimpleContetAccessPath)
    .reply(202, true);

  const getscope = nockInstance
    .get(manifestHistoryPath)
    .query(true)
    .reply(200, manifestHistorySuccessResponse);

  const { getByTestId } = renderWithRedux(<ManifestModal {...defaultProps} />, { initialState });

  const toggleButton = getByTestId('switch');

  await patientlyWaitFor(() => { expect(toggleButton).toBeInTheDocument(); });
  expect(toggleButton.checked).toEqual(true);

  fireEvent.click(toggleButton);

  assertNockRequest(getscope);
  assertNockRequest(updatescope, done);
});
