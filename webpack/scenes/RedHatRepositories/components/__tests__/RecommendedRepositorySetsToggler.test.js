import { testComponentSnapshotsWithFixtures } from '../../../../move_to_pf/test-utils/testHelpers';

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
