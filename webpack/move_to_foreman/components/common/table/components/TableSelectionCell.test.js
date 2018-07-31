import { testComponentSnapshotsWithFixtures } from '../../../../../move_to_pf/test-utils/testHelpers';

import TableSelectionCell from './TableSelectionCell';

const fixtures = {
  'renders TableSelectionCell': {
    id: 'some id',
    before: 'some before',
    after: 'some after',
    label: 'some label',
    checked: true,
    onChange: jest.fn(),
  },
};

describe('TableSelectionCell', () => testComponentSnapshotsWithFixtures(TableSelectionCell, fixtures));
