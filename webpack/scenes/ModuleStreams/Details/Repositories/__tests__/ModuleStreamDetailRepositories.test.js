import ModuleStreamDetailRepositories from '../ModuleStreamDetailRepositories';
import { testComponentSnapshotsWithFixtures } from '../../../../../move_to_pf/test-utils/testHelpers';
import { details } from '../../__tests__/moduleStreamDetails.fixtures';

const fixtures = {
  'renders with repositories': {
    repositories: details.repositories,
  },
};

describe('Module stream detail repositories component', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(ModuleStreamDetailRepositories, fixtures));
});
