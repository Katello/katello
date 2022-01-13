import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';
import ContentDetailRepositories from '../ContentDetailRepositories';

const fixtures = {
  'renders with repositories': {
    repositories: [
      {
        id: 1,
        name: 'dummy name',
        product_id: 1,
        product_name: 'dummy product',
      },
    ],
  },
};

describe('Content detail repositories component', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(ContentDetailRepositories, fixtures));
});
