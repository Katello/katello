import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';
import ModuleStreamDetailArtifacts from '../ModuleStreamDetailArtifacts';
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
