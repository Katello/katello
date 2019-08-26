import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';
import ContentDetailInfo from '../../../../components/Content/Details/ContentDetailInfo';
import { details } from './moduleStreamDetails.fixtures';
import { displayMap } from '../ModuleDetailsSchema';

const fixtures = {
  'renders with module stream info': {
    contentDetails: details,
    displayMap,
  },
};

describe('Module stream detail info component', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(ContentDetailInfo, fixtures));
});
