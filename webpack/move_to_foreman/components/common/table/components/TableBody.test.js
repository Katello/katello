import { testComponentSnapshotsWithFixtures } from '../../../../../move_to_pf/test-utils/testHelpers';

import TableBody from './TableBody';
import { columnsFixtures, rowsFixtures } from './TableFixtures';

const fixtures = {
  'renders TableBody': {
    columns: columnsFixtures,
    rows: rowsFixtures,
  },
  'renders TableBody with message': {
    columns: columnsFixtures,
    rows: rowsFixtures,
    message: 'some message',
  },
};

describe('TableBody', () => testComponentSnapshotsWithFixtures(TableBody, fixtures));
