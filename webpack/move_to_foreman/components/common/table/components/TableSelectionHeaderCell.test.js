import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';

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
