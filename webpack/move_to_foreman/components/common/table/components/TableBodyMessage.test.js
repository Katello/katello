import { testComponentSnapshotsWithFixtures } from '../../../../../move_to_pf/test-utils/testHelpers';

import TableBodyMessage from './TableBodyMessage';

const fixtures = {
  'renders TableBodyMessage': {
    colSpan: 2,
    children: 'some children',
  },
};

describe('TableBodyMessage', () => testComponentSnapshotsWithFixtures(TableBodyMessage, fixtures));
