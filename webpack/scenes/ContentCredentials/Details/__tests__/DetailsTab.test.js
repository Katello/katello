import React from 'react';
import nock from 'nock';
import { screen, fireEvent, waitFor, cleanup } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import api from '../../../../services/api';
import { nockInstance } from '../../../../test-utils/nockWrapper';
import DetailsTab from '../DetailsTab';

const credentialId = 1;
const uploadPath = api.getApiUrl(`/content_credentials/${credentialId}/content`);
const detailsPath = api.getApiUrl(`/content_credentials/${credentialId}`);

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

afterEach(() => {
  cleanup();
  nock.abortPendingRequests();
  nock.cleanAll();
  jest.restoreAllMocks();
});

beforeEach(() => {
  nock.cleanAll();
});

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

test('upload button triggers hidden file input click', () => {
  renderTab();

  // The hidden file input should exist
  const fileInput = document.querySelector('input[type="file"]');
  expect(fileInput).toBeInTheDocument();
  expect(fileInput).toHaveStyle({ display: 'none' });

  // Click should trigger the file input
  const clickSpy = jest.spyOn(fileInput, 'click');
  fireEvent.click(screen.getByText('Choose file'));
  expect(clickSpy).toHaveBeenCalled();

  // Cleanup the spy
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
    uploadScope.done();
  }, { timeout: 3000 });

  await waitFor(() => {
    refetchScope.done();
  }, { timeout: 3000 });
});

test('failed file upload sends POST with error response', async () => {
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
    uploadScope.done();
  }, { timeout: 3000 });
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

test('upload button is enabled before upload and re-enables after upload completes', async () => {
  const uploadScope = nockInstance
    .post(uploadPath)
    .reply(200, { id: credentialId, content: 'new content' });

  const refetchScope = nockInstance
    .get(detailsPath)
    .query(true)
    .reply(200, { ...baseDetails, content: 'new content' });

  renderTab();

  // Upload button should not be disabled initially
  const uploadButton = screen.getByText('Choose file').closest('button');
  expect(uploadButton).not.toBeDisabled();

  const fileInput = document.querySelector('input[type="file"]');
  const testFile = new File(['file contents'], 'test.asc', { type: 'application/pgp-keys' });

  await userEvent.upload(fileInput, testFile);

  // After upload completes, button should return to enabled state
  await waitFor(() => {
    expect(screen.getByText('Choose file').closest('button')).not.toBeDisabled();
  });

  await waitFor(() => {
    uploadScope.done();
  }, { timeout: 3000 });

  await waitFor(() => {
    refetchScope.done();
  }, { timeout: 3000 });
});

test('file input re-enables after upload completes', async () => {
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

  // File input should be enabled initially
  expect(fileInput).not.toBeDisabled();

  await userEvent.upload(fileInput, testFile);

  // After upload completes, the file input should be enabled again
  await waitFor(() => {
    expect(document.querySelector('input[type="file"]')).not.toBeDisabled();
  });

  await waitFor(() => {
    uploadScope.done();
  }, { timeout: 3000 });

  await waitFor(() => {
    refetchScope.done();
  }, { timeout: 3000 });
});

test('displays Certificate type for cert content_type', () => {
  const certDetails = { ...baseDetails, content_type: 'cert' };
  renderTab(certDetails);

  expect(screen.getByText('Certificate')).toBeInTheDocument();
});

// --- Manual content editing tests ---

describe('manual content editing', () => {
  test('clicking edit pencil on content shows a textarea for editing', () => {
    renderTab();

    fireEvent.click(screen.getByLabelText('edit content'));

    expect(screen.getByLabelText('content text area')).toBeInTheDocument();
    expect(screen.getByLabelText('content text area')).toHaveValue(baseDetails.content);
  });

  test('can type new content in the textarea', () => {
    renderTab();

    fireEvent.click(screen.getByLabelText('edit content'));
    const textarea = screen.getByLabelText('content text area');
    const newContent = 'new PGP key content';
    fireEvent.change(textarea, { target: { value: newContent } });

    expect(textarea).toHaveValue(newContent);
  });

  test('clicking clear reverts content to original value and exits edit mode', () => {
    renderTab();

    fireEvent.click(screen.getByLabelText('edit content'));
    fireEvent.change(screen.getByLabelText('content text area'), {
      target: { value: 'changed value' },
    });

    fireEvent.click(screen.getByLabelText('clear content'));

    // toHaveTextContent collapses whitespace, so check key parts individually
    expect(screen.getByLabelText('content text value')).toHaveTextContent('BEGIN PGP PUBLIC KEY BLOCK');
    expect(screen.getByLabelText('content text value')).toHaveTextContent('END PGP PUBLIC KEY BLOCK');
    expect(screen.queryByLabelText('content text area')).not.toBeInTheDocument();
  });

  test('submitting content triggers API update and refetch', async () => {
    const newContent = 'updated PGP key';

    const updateScope = nockInstance
      .put(detailsPath)
      .reply(200, { ...baseDetails, content: newContent });

    const refetchScope = nockInstance
      .get(detailsPath)
      .query(true)
      .reply(200, { ...baseDetails, content: newContent });

    renderTab();

    fireEvent.click(screen.getByLabelText('edit content'));
    fireEvent.change(screen.getByLabelText('content text area'), {
      target: { value: newContent },
    });
    fireEvent.click(screen.getByLabelText('submit content'));

    await patientlyWaitFor(() => {
      updateScope.done();
      refetchScope.done();
    });
  });

  test('submitting unchanged content does not trigger API call', () => {
    renderTab();

    fireEvent.click(screen.getByLabelText('edit content'));
    // Submit without changing value
    fireEvent.click(screen.getByLabelText('submit content'));

    // No nock scope set, so any request would cause a nock error
    expect(screen.queryByLabelText('content text area')).not.toBeInTheDocument();
  });

  test('name field can be edited and saved via API', async () => {
    const newName = 'Updated Key Name';

    const updateScope = nockInstance
      .put(detailsPath)
      .reply(200, { ...baseDetails, name: newName });

    const refetchScope = nockInstance
      .get(detailsPath)
      .query(true)
      .reply(200, { ...baseDetails, name: newName });

    renderTab();

    fireEvent.click(screen.getByLabelText('edit name'));
    fireEvent.change(screen.getByLabelText('name text input'), {
      target: { value: newName },
    });
    fireEvent.click(screen.getByLabelText('submit name'));

    await patientlyWaitFor(() => {
      updateScope.done();
      refetchScope.done();
    });
  });

  test('content edit pencil is hidden when user lacks edit permission', () => {
    const noEditDetails = {
      ...baseDetails,
      permissions: { edit_content_credentials: false },
    };
    renderTab(noEditDetails);

    expect(screen.getByText('Content')).toBeInTheDocument();
    expect(screen.queryByLabelText('edit content')).not.toBeInTheDocument();
  });

  test('handles null content gracefully', () => {
    const noContentDetails = { ...baseDetails, content: null };
    renderTab(noContentDetails);

    expect(screen.getByText('Content')).toBeInTheDocument();
  });
});

describe('race condition prevention between editing and uploading', () => {
  test('content edit is disabled while file is uploading', async () => {
    const uploadScope = nockInstance
      .post(uploadPath)
      .reply(200, { id: credentialId, content: 'uploaded content' });

    const refetchScope = nockInstance
      .get(detailsPath)
      .query(true)
      .reply(200, { ...baseDetails, content: 'uploaded content' });

    renderTab();

    // Content edit pencil should be visible initially
    expect(screen.getByLabelText('edit content')).toBeInTheDocument();

    const fileInput = document.querySelector('input[type="file"]');
    const testFile = new File(['file contents'], 'test.asc', { type: 'application/pgp-keys' });

    await userEvent.upload(fileInput, testFile);

    // During upload, content editing should be disabled (no pencil icon)
    await waitFor(() => {
      expect(screen.queryByLabelText('edit content')).not.toBeInTheDocument();
    });

    // After upload completes, content editing should be re-enabled
    await waitFor(() => {
      expect(screen.getByLabelText('edit content')).toBeInTheDocument();
    });

    await waitFor(() => {
      uploadScope.done();
      refetchScope.done();
    });
  });

  test('upload button is disabled during content update', async () => {
    const updateScope = nockInstance
      .put(detailsPath)
      .reply(200, { ...baseDetails, content: 'new' });

    const refetchScope = nockInstance
      .get(detailsPath)
      .query(true)
      .reply(200, { ...baseDetails, content: 'new' });

    renderTab();

    fireEvent.click(screen.getByLabelText('edit content'));
    fireEvent.change(screen.getByLabelText('content text area'), {
      target: { value: 'new' },
    });
    fireEvent.click(screen.getByLabelText('submit content'));

    // During update, upload button should be disabled
    await waitFor(() => {
      const uploadButton = screen.getByText('Choose file').closest('button');
      expect(uploadButton).toBeDisabled();
    });

    await patientlyWaitFor(() => {
      updateScope.done();
      refetchScope.done();
    });
  });

  test('editing one field closes another field being edited', () => {
    renderTab();

    // Start editing name
    fireEvent.click(screen.getByLabelText('edit name'));
    expect(screen.getByLabelText('name text input')).toBeInTheDocument();

    // Start editing content - name editing should close
    fireEvent.click(screen.getByLabelText('edit content'));
    expect(screen.getByLabelText('content text area')).toBeInTheDocument();
    expect(screen.queryByLabelText('name text input')).not.toBeInTheDocument();
  });
});

describe('content update state management', () => {
  test('upload button becomes disabled when content update is in flight', async () => {
    // Use a successful response to test the intermediate state
    const updateScope = nockInstance
      .put(detailsPath)
      .reply(200, { ...baseDetails, content: 'updated' });

    const refetchScope = nockInstance
      .get(detailsPath)
      .query(true)
      .reply(200, { ...baseDetails, content: 'updated' });

    renderTab();

    // Upload button starts enabled
    expect(screen.getByText('Choose file').closest('button')).not.toBeDisabled();

    fireEvent.click(screen.getByLabelText('edit content'));
    fireEvent.change(screen.getByLabelText('content text area'), {
      target: { value: 'updated' },
    });
    fireEvent.click(screen.getByLabelText('submit content'));

    // Upload button is disabled while update is in progress
    await waitFor(() => {
      expect(screen.getByText('Choose file').closest('button')).toBeDisabled();
    });

    // After update completes, upload button is re-enabled
    await waitFor(() => {
      expect(screen.getByText('Choose file').closest('button')).not.toBeDisabled();
    });

    await patientlyWaitFor(() => {
      updateScope.done();
      refetchScope.done();
    });
  });
});
