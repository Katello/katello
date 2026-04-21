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

import { nockInstance } from '../../../../../../test-utils/nockWrapper';
import api from '../../../../../../services/api';
import BulkDeleteModal from '../BulkDeleteModal';
import contentViewData from './contentView.fixtures.json';
import contentViewVersionData from './contentViewVersion.fixtures.json';
import contentViewVersionDataWithoutHostgroups from './contentViewVersionWithoutHostgroups.fixtures.json';
import environmentPaths from './environmentPaths.fixtures.json';
import hostsData from './hosts.fixtures.json';
import cvDetailsData from './cvDetails.fixtures.json';
import cvEnvironmentsData from './cvEnvironments.fixtures.json';

const { results: versions } = contentViewVersionData;
const { results: versionsWithoutHostgroups } = contentViewVersionDataWithoutHostgroups;
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
      CONTENT_VIEWS_10: {
        response: cvDetailsData, status: STATUS.RESOLVED,
      },
    },
    katello: {
      hostDetails: {},
    },
  },
};

const renderOptionsWithoutHostgroups = {
  ...renderOptions,
  initialState: {
    ...renderOptions.initialState,
    API: {
      ...renderOptions.initialState.API,
      CONTENT_VIEW_VERSIONS_10: {
        response: contentViewVersionDataWithoutHostgroups, status: STATUS.RESOLVED,
      },
    },
  },
};

jest.mock('react-redux', () => ({
  ...jest.requireActual('react-redux'), // This leaves the rest of the imports unchanged
  useSelector: jest.fn(),
}));

// clean-up mocks
afterEach(() => {
  useSelector.mockClear();
});

afterAll(() => {
  jest.clearAllMocks();
});

// https://kentcdodds.com/blog/write-fewer-longer-tests

test('Open bulk delete modal and step through all steps', () => {
  useSelector.mockImplementation(selector =>
    selector(renderOptionsWithoutHostgroups.initialState));

  renderWithRedux(
    <Route path="/content_views/:id">
      <div>
        <BulkDeleteModal
          versions={versionsWithoutHostgroups}
          onClose={() => { }}
        />
      </div>
    </Route>,
    renderOptionsWithoutHostgroups,
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
});

test('Open bulk delete modal with hostgroups and step through all steps', () => {
  useSelector.mockImplementation(selector =>
    selector(renderOptions.initialState));

  const cvEnvPath = api.getApiUrl('/content_view_environments');
  nockInstance
    .get(cvEnvPath)
    .query(true)
    .reply(200, cvEnvironmentsData);

  const cvDropdownPath = api.getApiUrl('/content_views');
  nockInstance
    .get(cvDropdownPath)
    .query(true)
    .times(3)
    .reply(200, contentViewData);

  // Mock hosts API calls (needed when selecting CV/LCE for hosts reassignment)
  nockInstance
    .get('/api/v2/hosts/auto_complete_search')
    .query(true)
    .times(10)
    .reply(200, []);

  nockInstance
    .get('/api/v2/hosts')
    .query(true)
    .times(10)
    .reply(200, hostsData);

  // Mock activation keys API calls (needed when selecting CV/LCE for activation keys reassignment)
  nockInstance
    .get('/katello/api/v2/activation_keys/auto_complete_search')
    .query(true)
    .times(10)
    .reply(200, []);

  nockInstance
    .get('/katello/api/v2/activation_keys')
    .query(true)
    .times(10)
    .reply(200, { results: [] });

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
  expect(getByText('Reassign affected host groups')).toBeInTheDocument();

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

  // Test "Reassign affected host groups" step
  expect(queryAllByText('Reassign affected host groups')).toHaveLength(3);
  expect(getByText(/host groups that need to be reassigned/i)).toBeInTheDocument();

  // Expand hostgroups table
  fireEvent.click(getByText('Show host groups'));
  expect(getByText('HG10')).toBeInTheDocument();
  expect(getByText('HG20')).toBeInTheDocument();

  // Select environment and CV for hostgroups
  const libraryRadios = getAllByLabelText('Library', { selector: 'input' });
  // Click the last Library radio (for hostgroups)
  fireEvent.click(libraryRadios[libraryRadios.length - 1]);

  const optionsMenus = getAllByLabelText('Options menu');
  // Click the last Options menu (for hostgroups)
  fireEvent.click(optionsMenus[optionsMenus.length - 1]);
  fireEvent.click(queryByText('Eeloo'));

  expect(queryByText('Next')).toHaveAttribute('aria-disabled', 'false');
  fireEvent.click(queryByText('Next'));

  // Test "Reassign affected activation keys" step
  expect(queryAllByText('Reassign affected activation key')).toHaveLength(3);

  // Environment and CV should be inherited from previous step enabling next button
  expect(queryByText('Next')).toHaveAttribute('aria-disabled', 'false');
  fireEvent.click(queryByText('Next'));

  // Test "Review details" step
  expect(queryAllByText('Review details')).toHaveLength(3);
  // Just verify hostgroups section exists - FormattedMessage rendering in tests can be tricky
  expect(getByText('Host groups')).toBeInTheDocument();

  // Expect "Delete" button to be enabled
  expect(queryByText('Delete')).toHaveAttribute('aria-disabled', 'false');
  fireEvent.click(queryByText('Delete'));

  // Test "FinishBulkDelete" loading page
  expect(queryByText('Please wait while the task starts..')).toBeInTheDocument();
});
