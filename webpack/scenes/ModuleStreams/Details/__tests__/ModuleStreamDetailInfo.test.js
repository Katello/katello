import ModuleStreamDetailInfo from '../ModuleStreamDetailInfo';
import { testComponentSnapshotsWithFixtures } from '../../../../move_to_pf/test-utils/testHelpers';
import { details } from './moduleStreamDetails.fixtures';

const fixtures = {
  'renders with module stream info': {
    moduleStreamDetails: details,
  },
};

describe('Module stream detail info component', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(ModuleStreamDetailInfo, fixtures));
});
