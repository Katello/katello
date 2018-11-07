import ModuleStreamDetailProfiles from '../ModuleStreamDetailProfiles';
import { testComponentSnapshotsWithFixtures } from '../../../../../move_to_pf/test-utils/testHelpers';
import { details } from '../../__tests__/moduleStreamDetails.fixtures';

jest.mock('foremanReact/components/Pagination/PaginationWrapper');

const fixtures = {
  'renders with profiles': {
    profiles: details.profiles,
  },
};

describe('Module stream detail profiles component', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(ModuleStreamDetailProfiles, fixtures));
});
