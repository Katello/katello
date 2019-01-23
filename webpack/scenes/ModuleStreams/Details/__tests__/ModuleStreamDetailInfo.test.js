import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';
import ModuleStreamDetailInfo from '../ModuleStreamDetailInfo';
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
