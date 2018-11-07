import ModuleStreamDetails from '../ModuleStreamDetails';
import { testComponentSnapshotsWithFixtures } from '../../../../move_to_pf/test-utils/testHelpers';
import { details, loadingState } from './moduleStreamDetails.fixtures';

jest.mock('foremanReact/components/Pagination/PaginationWrapper');

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
