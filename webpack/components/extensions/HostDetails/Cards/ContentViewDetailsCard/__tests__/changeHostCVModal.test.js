import React from 'react';
import { renderWithRedux, patientlyWaitFor, act } from 'react-testing-lib-wrapper';
import userEvent from '@testing-library/user-event';
import ChangeHostCVModal from '../ChangeHostCVModal';
import mockEnvPaths from './envPaths.fixtures.json';
import mockContentViews from './contentViews.fixtures.json';
import HOST_CV_AND_ENV_KEY from '../HostContentViewConstants';
import { assertNockRequest, nockInstance } from '../../../../../../test-utils/nockWrapper';
import katelloApi from '../../../../../../services/api';

const contentViews = katelloApi.getApiUrl('/content_views');
// const hostDetailsUrl = '/api/hosts/test-host';

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
  const { getAllByText }
     = renderWithRedux(<ChangeHostCVModal
       isOpen
       closeModal={jest.fn()}
       hostId={1}
       hostName="test-host"
       hostEnvId={1}
       orgId={1}
     />, renderOptions());

  await patientlyWaitFor(() =>
    expect(getAllByText(firstEnv.name)[0]).toBeInTheDocument());
  done();
});

test('Select an env > call CV API > select a CV > Save button is enabled', async (done) => {
  const contentViewsScope = nockInstance
    .get(contentViews)
    .query(cvQuery)
    .reply(200, mockContentViews);

  const {
    getAllByText, getByText,
    findByPlaceholderText, getAllByRole,
  } = renderWithRedux(<ChangeHostCVModal
    isOpen
    closeModal={jest.fn()}
    hostId={1}
    hostName="test-host"
    hostEnvId={1}
    orgId={1}
  />, renderOptions());

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

  assertNockRequest(contentViewsScope);
  done();
  act(done);
});
