import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';
import ModuleStreamDetailRepositories from '../ModuleStreamDetailRepositories';
import { details } from '../../__tests__/moduleStreamDetails.fixtures';

jest.mock('foremanReact/components/Pagination/PaginationWrapper');

const fixtures = {
  'renders with repositories': {
    repositories: details.repositories,
  },
};

describe('Module stream detail repositories component', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(ModuleStreamDetailRepositories, fixtures));
});
