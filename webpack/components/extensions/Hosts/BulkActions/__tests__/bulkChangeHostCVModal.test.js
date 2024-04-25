import React from 'react';
import { renderWithRedux, patientlyWaitFor, act } from 'react-testing-lib-wrapper';
import userEvent from '@testing-library/user-event';
import BulkChangeHostCVModal from '../BulkChangeHostCVModal/BulkChangeHostCVModal.js';
import mockEnvPaths from '../../../HostDetails/Cards/ContentViewDetailsCard/__tests__/envPaths.fixtures.json';
import mockContentViews from '../../../HostDetails/Cards/ContentViewDetailsCard/__tests__/contentViews.fixtures.json';
import HOST_CV_AND_ENV_KEY from '../../../HostDetails/Cards/ContentViewDetailsCard/HostContentViewConstants';
import { assertNockRequest, nockInstance } from '../../../../../test-utils/nockWrapper';
import katelloApi from '../../../../../services/api';

const contentViews = katelloApi.getApiUrl('/content_views');
const renderOptions = () => ({
  apiNamespace: HOST_CV_AND_ENV_KEY,
  initialState: {
    API: {
      HOST_DETAILS: {
        response: {
          id: 1,
          name: 'test-host',
          content_facet_attributes: {
            content_view_id: 1,
            lifecycle_environment_id: 1,
          },
          organization_id: 1,
        },
        status: 'RESOLVED',
      },
      ENVIRONMENT_PATHS: {
        response: mockEnvPaths,
        status: 'RESOLVED',
      },
    },
  },
});

let firstEnvPath;
let firstCV;
let secondCV;
let firstEnv;

const cvQuery = {
  organization_id: 1,
  include_permissions: true,
  include_default: true,
  environment_id: 1,
  full_result: true,
  order: 'default DESC',
};

beforeEach(() => {
  const { results } = mockEnvPaths;
  [firstEnvPath] = results;
  const { environments: envResults } = firstEnvPath;
  [firstEnv] = envResults;
  const { results: cvResults } = mockContentViews;
  [firstCV, secondCV] = cvResults;
});

jest.mock('foremanReact/common/hooks/API/APIHooks', () => ({
  useAPI: jest.fn(),
}));

test('Displays environment paths', async (done) => {
  const jsx = (
    <BulkChangeHostCVModal
      isOpen
      closeModal={jest.fn()}
      selectedCount={1}
      fetchBulkParams={() => 'id ^ 1'}
      orgId={1}
    />
  );
  const { getAllByText }
     = renderWithRedux(jsx, renderOptions());

  await patientlyWaitFor(() =>
    expect(getAllByText(firstEnv.name)[0]).toBeInTheDocument());
  done();
});

test('Select an env > call CV API > select a CV > Save button is enabled', async (done) => {
  const contentViewsScope = nockInstance
    .get(contentViews)
    .query(cvQuery)
    .reply(200, mockContentViews);

  const jsx = (
    <BulkChangeHostCVModal
      isOpen
      closeModal={jest.fn()}
      selectedCount={1}
      fetchBulkParams={() => 'id ^ 1'}
      orgId={1}
    />
  );
  const {
    getAllByText, getByText,
    findByPlaceholderText, getAllByRole,
  } = renderWithRedux(jsx, renderOptions());

  await patientlyWaitFor(() => {
    const envLabel = getAllByText(firstEnv.name)[0];
    expect(envLabel).toBeInTheDocument();
  });

  const envRadio = getAllByRole('radio', { name: firstEnv.name })[0];
  expect(envRadio).toBeInTheDocument();

  await act(async () => {
    userEvent.click(envRadio); // Select the Library environment

    const cvDropdown = await findByPlaceholderText('Select a content view');
    expect(cvDropdown).toBeInTheDocument();

    userEvent.click(cvDropdown); // Open the CV dropdown


    [firstCV, secondCV].forEach((cv) => {
      expect(getByText(cv.name)).toBeInTheDocument(); // the content view names should be showing
    });


    userEvent.click(getByText(secondCV.name)); // Select the second content view
  });

  // find the Save button and assert that it is enabled
  const saveButton = getAllByRole('button', { name: 'Save' })[0];
  expect(saveButton).toBeInTheDocument();
  expect(saveButton).toHaveAttribute('aria-disabled', 'false');

  assertNockRequest(contentViewsScope, done);
  act(done);
});
