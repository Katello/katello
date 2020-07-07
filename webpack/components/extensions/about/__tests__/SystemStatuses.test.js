import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';

import SystemStatuses from '../SystemStatuses';
import { withServices, pending } from './SystemStatuses.fixtures';

jest.unmock('../../../../components/LoadingState');

const fixtures = {
  'renders a table': withServices,
  'renders a loader': pending,
};

describe('SystemStatuses', () =>
  testComponentSnapshotsWithFixtures(SystemStatuses, fixtures));
