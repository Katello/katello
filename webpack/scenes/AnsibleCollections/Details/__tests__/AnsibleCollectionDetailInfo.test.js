import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';
import ContentDetailInfo from '../../../../components/Content/Details/ContentDetailInfo';
import { details } from './AnsibleCollectionDetails.fixtures';
import { displayMap } from '../AnsibleCollectionsSchema';

const fixtures = {
  'renders with ansible collection info': {
    contentDetails: details,
    displayMap,
  },
};

describe('Ansible Collection detail info component', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(ContentDetailInfo, fixtures));
});
