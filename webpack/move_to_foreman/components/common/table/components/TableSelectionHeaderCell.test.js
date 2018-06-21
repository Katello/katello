import { testComponentSnapshotsWithFixtures } from '../../../../../move_to_pf/test-utils/testHelpers';

import TableSelectionHeaderCell from './TableSelectionHeaderCell';

const fixtures = {
  'renders TableSelectionHeaderCell': {
    id: 'some id',
    label: 'some label',
    checked: true,
    onChange: jest.fn(),
  },
};

describe('TableSelectionHeaderCell', () => testComponentSnapshotsWithFixtures(TableSelectionHeaderCell, fixtures));
