import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';

import RecommendedRepositorySetsToggler from '../RecommendedRepositorySetsToggler';

const fixtures = {
  'renders recommended-repository-sets-toggler': {
    enabled: true,
    className: 'some-class-name',
    children: 'some-children',
    help: 'some-help',
    onChange: () => null,
  },
};

describe('RecommendedRepositorySetsToggler', () => {
  describe('rendering', () => testComponentSnapshotsWithFixtures(RecommendedRepositorySetsToggler, fixtures));
});
