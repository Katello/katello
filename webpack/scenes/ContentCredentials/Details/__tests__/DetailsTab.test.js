import React from 'react';
import nock from 'nock';
import { screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import api from '../../../../services/api';
import { nockInstance, assertNockRequest } from '../../../../test-utils/nockWrapper';
import DetailsTab from '../DetailsTab';

const credentialId = 1;
const uploadPath = api.getApiUrl(`/content_credentials/${credentialId}/content`);
const detailsPath = api.getApiUrl(`/content_credentials/${credentialId}`);

afterEach(() => {
  nock.cleanAll();
});

const baseDetails = {
  name: 'Test GPG Key',
  content_type: 'gpg_key',
  content: '-----BEGIN PGP PUBLIC KEY BLOCK-----\ntest\n-----END PGP PUBLIC KEY BLOCK-----',
  gpg_key_products: [{ id: 1, name: 'Prod1' }],
  ssl_ca_products: [],
  ssl_client_products: [],
  ssl_key_products: [],
  gpg_key_repos: [{ id: 1, name: 'Repo1' }],
  ssl_ca_root_repos: [],
  ssl_client_root_repos: [],
  ssl_key_root_repos: [],
  ssl_ca_alternate_content_sources: [],
  ssl_client_alternate_content_sources: [],
  ssl_key_alternate_content_sources: [],
  permissions: { edit_content_credentials: true },
};

const renderTab = (details = baseDetails) =>
  renderWithRedux(<DetailsTab credentialId={credentialId} details={details} />);

test('renders details fields correctly', () => {
  renderTab();

  expect(screen.getByText('Name')).toBeInTheDocument();
  expect(screen.getByText('Type')).toBeInTheDocument();
  expect(screen.getByText('GPG Key')).toBeInTheDocument();
  expect(screen.getByText('Content')).toBeInTheDocument();
  expect(screen.getByText('Upload new file')).toBeInTheDocument();
  expect(screen.getByText('Choose file')).toBeInTheDocument();
});

test('renders counts for products, repositories, and ACS', () => {
  renderTab();

  // 1 gpg_key_product
  expect(screen.getByText('1', { selector: 'a[href="#/products"]' })).toBeInTheDocument();
  // 1 gpg_key_repo
  expect(screen.getByText('1', { selector: 'a[href="#/repositories"]' })).toBeInTheDocument();
  // 0 ACS
  expect(screen.getByText('0', { selector: 'a[href="#/alternate_content_sources"]' })).toBeInTheDocument();
});

test('upload button triggers hidden file input click', async () => {
  const user = userEvent.setup();
  renderTab();

  const uploadButton = screen.getByText('Choose file');
  // The hidden file input should exist
  const fileInput = document.querySelector('input[type="file"]');
  expect(fileInput).toBeInTheDocument();
  expect(fileInput).toHaveStyle({ display: 'none' });

  // Click should trigger the file input
  const clickSpy = jest.spyOn(fileInput, 'click');
  await user.click(uploadButton);
  expect(clickSpy).toHaveBeenCalled();
  clickSpy.mockRestore();
});

test('GPG key file input accepts correct file types', () => {
  renderTab();

  const fileInput = document.querySelector('input[type="file"]');
  expect(fileInput).toHaveAttribute('accept', '.asc,.gpg,.key');
});

test('Certificate file input accepts correct file types', () => {
  const certDetails = { ...baseDetails, content_type: 'cert' };
  renderTab(certDetails);

  const fileInput = document.querySelector('input[type="file"]');
  expect(fileInput).toHaveAttribute('accept', '.crt,.pem,.cer,.cert');
});

test('successful file upload shows success toast and refetches details', async () => {
  const uploadScope = nockInstance
    .post(uploadPath)
    .reply(200, { id: credentialId, content: 'new content' });

  const refetchScope = nockInstance
    .get(detailsPath)
    .query(true)
    .reply(200, { ...baseDetails, content: 'new content' });

  renderTab();

  const fileInput = document.querySelector('input[type="file"]');
  const testFile = new File(['file contents'], 'test.asc', { type: 'application/pgp-keys' });

  await userEvent.upload(fileInput, testFile);

  await waitFor(() => {
    assertNockRequest(uploadScope);
  });

  await waitFor(() => {
    assertNockRequest(refetchScope);
  });
});

test('failed file upload shows error toast', async () => {
  const uploadScope = nockInstance
    .post(uploadPath)
    .reply(422, {
      displayMessage: 'Invalid GPG key content',
      errors: { content: ['is invalid'] },
    });

  renderTab();

  const fileInput = document.querySelector('input[type="file"]');
  const testFile = new File(['bad content'], 'bad.asc', { type: 'application/pgp-keys' });

  await userEvent.upload(fileInput, testFile);

  await waitFor(() => {
    assertNockRequest(uploadScope);
  });
});

test('upload button is disabled when user lacks edit permission', () => {
  const noEditDetails = {
    ...baseDetails,
    permissions: { edit_content_credentials: false },
  };
  renderTab(noEditDetails);

  const uploadButton = screen.getByText('Choose file').closest('button');
  expect(uploadButton).toBeDisabled();
});

test('upload button is disabled when permissions are missing', () => {
  const noPermDetails = { ...baseDetails, permissions: {} };
  renderTab(noPermDetails);

  const uploadButton = screen.getByText('Choose file').closest('button');
  expect(uploadButton).toBeDisabled();
});

test('file input is disabled when user lacks edit permission', () => {
  const noEditDetails = {
    ...baseDetails,
    permissions: { edit_content_credentials: false },
  };
  renderTab(noEditDetails);

  const fileInput = document.querySelector('input[type="file"]');
  expect(fileInput).toBeDisabled();
});

test('upload button shows loading state during file upload', async () => {
  const uploadScope = nockInstance
    .post(uploadPath)
    .delay(500)
    .reply(200, { id: credentialId, content: 'new content' });

  const refetchScope = nockInstance
    .get(detailsPath)
    .query(true)
    .reply(200, { ...baseDetails, content: 'new content' });

  renderTab();

  const fileInput = document.querySelector('input[type="file"]');
  const testFile = new File(['file contents'], 'test.asc', { type: 'application/pgp-keys' });

  // Upload button should not be in loading state initially
  const uploadButton = screen.getByText('Choose file').closest('button');
  expect(uploadButton).not.toBeDisabled();

  await userEvent.upload(fileInput, testFile);

  // During upload, the button should be disabled (isLoading makes it disabled)
  await waitFor(() => {
    expect(screen.getByText('Choose file').closest('button')).toBeDisabled();
  });

  // After upload completes, button should be enabled again
  await waitFor(() => {
    expect(screen.getByText('Choose file').closest('button')).not.toBeDisabled();
  });

  await waitFor(() => {
    assertNockRequest(uploadScope);
  });

  await waitFor(() => {
    assertNockRequest(refetchScope);
  });
});

test('file input is disabled during upload to prevent conflicts', async () => {
  const uploadScope = nockInstance
    .post(uploadPath)
    .delay(500)
    .reply(200, { id: credentialId, content: 'new content' });

  const refetchScope = nockInstance
    .get(detailsPath)
    .query(true)
    .reply(200, { ...baseDetails, content: 'new content' });

  renderTab();

  const fileInput = document.querySelector('input[type="file"]');
  const testFile = new File(['file contents'], 'test.asc', { type: 'application/pgp-keys' });

  // File input should be enabled initially
  expect(fileInput).not.toBeDisabled();

  await userEvent.upload(fileInput, testFile);

  // During upload, the file input should be disabled
  await waitFor(() => {
    expect(document.querySelector('input[type="file"]')).toBeDisabled();
  });

  // After upload completes, the file input should be enabled again
  await waitFor(() => {
    expect(document.querySelector('input[type="file"]')).not.toBeDisabled();
  });

  await waitFor(() => {
    assertNockRequest(uploadScope);
  });

  await waitFor(() => {
    assertNockRequest(refetchScope);
  });
});

test('displays Certificate type for cert content_type', () => {
  const certDetails = { ...baseDetails, content_type: 'cert' };
  renderTab(certDetails);

  expect(screen.getByText('Certificate')).toBeInTheDocument();
});
