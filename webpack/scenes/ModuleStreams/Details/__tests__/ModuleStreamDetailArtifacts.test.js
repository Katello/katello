import ModuleStreamDetailArtifacts from '../ModuleStreamDetailArtifacts';
import { testComponentSnapshotsWithFixtures } from '../../../../move_to_pf/test-utils/testHelpers';
import { details } from './moduleStreamDetails.fixtures';

const fixtures = {
  'renders with artifacts': {
    artifacts: details.artifacts,
  },
};

describe('Module stream detail artifacts component', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(ModuleStreamDetailArtifacts, fixtures));
});
