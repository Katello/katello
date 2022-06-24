import React from 'react';

import { STATUS } from 'foremanReact/constants';
import { first } from 'lodash';
import { useSelector } from 'react-redux';
import { Route } from 'react-router-dom';
import {
  fireEvent,
  renderWithRedux,
  screen,
} from 'react-testing-lib-wrapper';

import nock from '../../../../../../test-utils/nockWrapper';
import BulkDeleteModal from '../BulkDeleteModal';
import contentViewData from './contentView.fixtures.json';
import contentViewVersionData from './contentViewVersion.fixtures.json';
import environmentPaths from './environmentPaths.fixtures.json';
import hostsData from './hosts.fixtures.json';

const { results: versions } = contentViewVersionData;
const {
  queryByText, queryAllByText, getByText, getAllByLabelText, getByLabelText,
} = screen;

const renderOptions = {
  routerParams: {
    initialEntries: [{ pathname: '/content_views/10' }],
    initialIndex: 1,
  },
  initialState: {
    // This is the API state that your tests depend on for their data
    // You can cross reference the needed useSelectors from your tested components
    // with the data found within the redux chrome add-on to help determine this fixture data.
    API: {
      ENVIRONMENT_PATHS: { response: environmentPaths, status: STATUS.RESOLVED },
      HOSTS_KEY: { response: hostsData, status: STATUS.RESOLVED },
      CONTENT_VIEW_VERSIONS_10: {
        response: contentViewVersionData, status: STATUS.RESOLVED,
      },
      CONTENT_VIEWS: {
        response: contentViewData, status: STATUS.RESOLVED,
      },
    },
    katello: {
      hostDetails: {},
    },
  },
};

jest.mock('react-redux', () => ({
  ...jest.requireActual('react-redux'), // This leaves the rest of the imports unchanged
  useSelector: jest.fn(),
}));

beforeAll(() => {
  useSelector.mockImplementation(selector =>
    // This is the data that your useSelectors will query against when needed.
    selector(renderOptions.initialState));
});

// clean-up mocks
afterAll(() => {
  useSelector.mockClear();
  jest.clearAllMocks();
});

// https://kentcdodds.com/blog/write-fewer-longer-tests

test('Open bulk delete modal and step through all steps', () => {
  renderWithRedux(
    <Route path="/content_views/:id">
      <div>
        <BulkDeleteModal
          versions={versions}
          onClose={() => { }}
        />
      </div>
    </Route>,
    renderOptions,
  );
  // Test "Review affected environments" step
  expect(queryByText('Delete versions')).toBeInTheDocument();
  expect(queryAllByText('Review affected environments')).toHaveLength(3);
  expect(getByText('Reassign affected host')).toBeInTheDocument();
  expect(getByText('Reassign affected activation key')).toBeInTheDocument();
  expect(getByText('{versionOrVersions} {versionList} will be removed from the listed environments and will no longer be available for promotion.')).toBeInTheDocument();

  fireEvent.click(queryByText('Next'));

  // Test "Reassign affected host" step
  expect(queryAllByText('Reassign affected host')).toHaveLength(3);
  expect(getByText('Select an environment')).toBeInTheDocument();

  fireEvent.click(first(getAllByLabelText('Library', { selector: 'input' })));

  expect(queryByText('Select an environment above')).not.toBeInTheDocument();
  expect(queryByText('Next')).toHaveAttribute('aria-disabled', 'true');

  fireEvent.click(getByLabelText('Options menu'));

  expect(queryByText('Eeloo')).toBeInTheDocument();
  fireEvent.click(queryByText('Eeloo'));

  // After selecting a contentView expect the "Next" button to be enabled
  expect(queryByText('Next')).toHaveAttribute('aria-disabled', 'false');
  fireEvent.click(queryByText('Next'));

  // Test "Reassign affected activation keys" step
  expect(queryAllByText('Reassign affected activation key')).toHaveLength(3);

  // Environment and host should be inherited from previous step enabling next button
  expect(queryByText('Next')).toHaveAttribute('aria-disabled', 'false');
  fireEvent.click(queryByText('Next'));

  // Test "Review details" step
  expect(queryAllByText('Review details')).toHaveLength(3);

  // Expect "Delete button to be enabled"
  expect(queryByText('Delete')).toHaveAttribute('aria-disabled', 'false');
  fireEvent.click(queryByText('Delete'));

  // Test "FinishBulkDelete" loading page
  expect(queryByText('Please wait while the task starts..')).toBeInTheDocument();
  nock.abortPendingRequests();
});
