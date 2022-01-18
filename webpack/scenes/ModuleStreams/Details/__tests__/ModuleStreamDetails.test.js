import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';
import ModuleStreamDetails from '../ModuleStreamDetails';
import { details, loadingState } from './moduleStreamDetails.fixtures';

const mockFunc = jest.fn();

const baseProps = {
  loadModuleStreamDetails: mockFunc,
  location: { search: '' },
  history: { push: mockFunc },
  moduleStreamDetails: details,
  match: { params: { id: String(details.id) } },
};

const fixtures = {
  'renders with module stream provided': {
    ...baseProps,
  },
  'renders with loading state': {
    ...baseProps,
    moduleStreamDetails: loadingState,
  },
};

describe('Module stream details page', () => {
  describe('rendering', () => testComponentSnapshotsWithFixtures(ModuleStreamDetails, fixtures));
});
