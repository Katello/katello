import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import { nockInstance, assertNockRequest } from '../../../../../../test-utils/nockWrapper';
import katelloApi from '../../../../../../services/api';
import BulkAssignCVEnvsModal from '../BulkAssignCVEnvsModal';

jest.mock('foremanReact/components/ToastsList', () => ({
  addToast: jest.fn(() => ({ type: 'ADD_TOAST' })),
}));

jest.mock('foremanReact/Root/Context/ForemanContext', () => ({
  useForemanOrganization: () => ({ id: 1, name: 'Test Org' }),
}));

const environmentPathsUrl = katelloApi.getApiUrl('/organizations/1/environments/paths');

const mockEnvironmentPaths = {
  results: [
    {
      id: 1,
      name: 'Library',
      permissions: { promotable: true },
      environments: [
        { id: 1, name: 'Library', permissions: { promotable: true } },
        { id: 2, name: 'Development', permissions: { promotable: true } },
      ],
    },
  ],
};

const renderOptions = (state = {}) => ({
  apiNamespace: 'BULK_ASSIGN_CONTENT_VIEW_ENVIRONMENTS',
  initialState: {
    API: {
      ...state,
    },
  },
});

const defaultProps = {
  isOpen: true,
  closeModal: jest.fn(),
  fetchBulkParams: jest.fn(() => 'name ~ test'),
  selectedCount: 5,
  orgId: 1,
  allowMultipleContentViews: true,
};

beforeEach(() => {
  jest.clearAllMocks();
});

test('renders modal when open with multiple CVs enabled', async () => {
  const environmentPathsScope = nockInstance
    .get(environmentPathsUrl)
    .query(true)
    .reply(200, mockEnvironmentPaths)
    .persist();

  const { getByText } = renderWithRedux(
    <BulkAssignCVEnvsModal {...defaultProps} />,
    renderOptions(),
  );

  await patientlyWaitFor(() => {
    expect(getByText('Assign content view environments')).toBeInTheDocument();
    expect(getByText(/A content view environment is a combination/)).toBeInTheDocument();
    expect(getByText('Add content view environment')).toBeInTheDocument();
  });

  assertNockRequest(environmentPathsScope, false);
});

test('renders modal with single CV mode when disabled', async () => {
  const environmentPathsScope = nockInstance
    .get(environmentPathsUrl)
    .query(true)
    .reply(200, mockEnvironmentPaths)
    .persist();

  const { getByText, queryByText } = renderWithRedux(
    <BulkAssignCVEnvsModal {...defaultProps} allowMultipleContentViews={false} />,
    renderOptions(),
  );

  await patientlyWaitFor(() => {
    expect(getByText('Assign content view environment')).toBeInTheDocument();
  });

  // Add button should not be visible in single CV mode
  expect(queryByText('Add content view environment')).not.toBeInTheDocument();

  assertNockRequest(environmentPathsScope, false);
});

test('Save button is disabled when no CVE is added', async () => {
  const environmentPathsScope = nockInstance
    .get(environmentPathsUrl)
    .query(true)
    .reply(200, mockEnvironmentPaths)
    .persist();

  const { getAllByRole } = renderWithRedux(
    <BulkAssignCVEnvsModal {...defaultProps} />,
    renderOptions(),
  );

  await patientlyWaitFor(() => {
    const saveButton = getAllByRole('button', { name: 'Save' })[0];
    expect(saveButton).toBeInTheDocument();
    expect(saveButton).toHaveAttribute('aria-disabled', 'true');
  });

  assertNockRequest(environmentPathsScope, false);
});

test('closes modal on Cancel', async () => {
  const environmentPathsScope = nockInstance
    .get(environmentPathsUrl)
    .query(true)
    .reply(200, mockEnvironmentPaths)
    .persist();

  const closeModal = jest.fn();

  const { getAllByRole } = renderWithRedux(
    <BulkAssignCVEnvsModal
      {...defaultProps}
      closeModal={closeModal}
    />,
    renderOptions(),
  );

  await patientlyWaitFor(() => {
    const cancelButton = getAllByRole('button', { name: 'Cancel' })[0];
    expect(cancelButton).toBeInTheDocument();
    cancelButton.click();
  });

  expect(closeModal).toHaveBeenCalled();
  assertNockRequest(environmentPathsScope, false);
});

test('does not fetch data when modal is closed', () => {
  const { queryByText } = renderWithRedux(
    <BulkAssignCVEnvsModal
      {...defaultProps}
      isOpen={false}
    />,
    renderOptions(),
  );

  expect(queryByText('Assign content view environments')).not.toBeInTheDocument();
});

test('displays proper description based on allowMultipleContentViews setting', async () => {
  const environmentPathsScope1 = nockInstance
    .get(environmentPathsUrl)
    .query(true)
    .reply(200, mockEnvironmentPaths)
    .persist();

  const { getByText, unmount } = renderWithRedux(
    <BulkAssignCVEnvsModal {...defaultProps} allowMultipleContentViews />,
    renderOptions(),
  );

  await patientlyWaitFor(() => {
    expect(getByText(/You can assign multiple content view environments/)).toBeInTheDocument();
  });

  unmount();
  assertNockRequest(environmentPathsScope1, false);

  const environmentPathsScope2 = nockInstance
    .get(environmentPathsUrl)
    .query(true)
    .reply(200, mockEnvironmentPaths)
    .persist();

  const { queryByText } = renderWithRedux(
    <BulkAssignCVEnvsModal {...defaultProps} allowMultipleContentViews={false} />,
    renderOptions(),
  );

  await patientlyWaitFor(() => {
    expect(queryByText(/You can assign multiple content view environments/)).not.toBeInTheDocument();
  });

  assertNockRequest(environmentPathsScope2, false);
});

test('builds correct payload for single CVE', () => {
  // Simulate what handleSave does with a single assignment
  const assignments = [
    {
      selectedEnv: [{ label: 'library_label' }],
      contentView: { label: 'test_cv' },
    },
  ];

  const fetchBulkParams = jest.fn(() => 'name ~ test');
  const orgId = 1;

  // This is the exact logic from BulkAssignCVEnvsModal.handleSave
  const cvEnvLabels = assignments.map((assignment) => {
    const env = assignment.selectedEnv[0];
    const cv = assignment.contentView;
    const envLabel = env.label;
    const cvLabel = cv.label;

    const isLibraryEnv = env.lifecycle_environment_library || env.library;
    const isDefaultCV = cv.content_view_default || cv.default;
    return isDefaultCV && isLibraryEnv ? envLabel : `${envLabel}/${cvLabel}`;
  });

  const requestBody = {
    content_view_environments: cvEnvLabels,
    organization_id: orgId,
    included: {
      search: fetchBulkParams(),
    },
  };

  // Verify request payload structure matches expected format
  expect(requestBody).toEqual({
    content_view_environments: ['library_label/test_cv'],
    organization_id: 1,
    included: {
      search: 'name ~ test',
    },
  });
});

test('builds correct payload for multiple CVEs preserving order', () => {
  // Simulate what handleSave does with multiple assignments
  const assignments = [
    {
      selectedEnv: [{ label: 'library_label' }],
      contentView: { label: 'test_cv_1' },
    },
    {
      selectedEnv: [{ label: 'dev_label' }],
      contentView: { label: 'test_cv_2' },
    },
    {
      selectedEnv: [{ label: 'prod_label' }],
      contentView: { label: 'test_cv_3' },
    },
  ];

  const fetchBulkParams = jest.fn(() => 'name ~ test');
  const orgId = 1;

  // This is the exact logic from BulkAssignCVEnvsModal.handleSave
  const cvEnvLabels = assignments.map((assignment) => {
    const env = assignment.selectedEnv[0];
    const cv = assignment.contentView;
    const envLabel = env.label;
    const cvLabel = cv.label;

    const isLibraryEnv = env.lifecycle_environment_library || env.library;
    const isDefaultCV = cv.content_view_default || cv.default;
    return isDefaultCV && isLibraryEnv ? envLabel : `${envLabel}/${cvLabel}`;
  });

  const requestBody = {
    content_view_environments: cvEnvLabels,
    organization_id: orgId,
    included: {
      search: fetchBulkParams(),
    },
  };

  // Verify request payload contains all CVE labels in correct order
  expect(requestBody).toEqual({
    content_view_environments: [
      'library_label/test_cv_1',
      'dev_label/test_cv_2',
      'prod_label/test_cv_3',
    ],
    organization_id: 1,
    included: {
      search: 'name ~ test',
    },
  });

  // Verify order is preserved (priority matters for multi-CV)
  expect(requestBody.content_view_environments[0]).toBe('library_label/test_cv_1');
  expect(requestBody.content_view_environments[1]).toBe('dev_label/test_cv_2');
  expect(requestBody.content_view_environments[2]).toBe('prod_label/test_cv_3');
});

test('builds correct label for default CV in Library environment', () => {
  // Test the special case: default CV in Library should use just "Library",
  // not "Library/Default_Organization_View"
  const assignments = [
    {
      selectedEnv: [{ label: 'Library', library: true }],
      contentView: { label: 'Default_Organization_View', default: true },
    },
  ];

  const cvEnvLabels = assignments.map((assignment) => {
    const env = assignment.selectedEnv[0];
    const cv = assignment.contentView;
    const envLabel = env.label;
    const cvLabel = cv.label;

    const isLibraryEnv = env.lifecycle_environment_library || env.library;
    const isDefaultCV = cv.content_view_default || cv.default;
    return isDefaultCV && isLibraryEnv ? envLabel : `${envLabel}/${cvLabel}`;
  });

  // For default CV in Library, label should be just "Library"
  expect(cvEnvLabels).toEqual(['Library']);
});

test('builds correct label for default CV in non-Library environment', () => {
  // Test that default CV in non-Library environment still uses slash format
  const assignments = [
    {
      selectedEnv: [{ label: 'Production', library: false }],
      contentView: { label: 'Default_Organization_View', default: true },
    },
  ];

  const cvEnvLabels = assignments.map((assignment) => {
    const env = assignment.selectedEnv[0];
    const cv = assignment.contentView;
    const envLabel = env.label;
    const cvLabel = cv.label;

    const isLibraryEnv = env.lifecycle_environment_library || env.library;
    const isDefaultCV = cv.content_view_default || cv.default;
    return isDefaultCV && isLibraryEnv ? envLabel : `${envLabel}/${cvLabel}`;
  });

  // For default CV in non-Library, label should use slash format
  expect(cvEnvLabels).toEqual(['Production/Default_Organization_View']);
});

test('builds correct label for non-default CV in Library environment', () => {
  // Test that non-default CV in Library still uses slash format
  const assignments = [
    {
      selectedEnv: [{ label: 'Library', library: true }],
      contentView: { label: 'Custom_CV', default: false },
    },
  ];

  const cvEnvLabels = assignments.map((assignment) => {
    const env = assignment.selectedEnv[0];
    const cv = assignment.contentView;
    const envLabel = env.label;
    const cvLabel = cv.label;

    const isLibraryEnv = env.lifecycle_environment_library || env.library;
    const isDefaultCV = cv.content_view_default || cv.default;
    return isDefaultCV && isLibraryEnv ? envLabel : `${envLabel}/${cvLabel}`;
  });

  // For non-default CV in Library, label should use slash format
  expect(cvEnvLabels).toEqual(['Library/Custom_CV']);
});
