import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';
import Table from './Table';
import { columnsFixtures, rowsFixtures } from './TableFixtures';

const fixtures = {
  'renders Table with emptyState': {
    columns: columnsFixtures,
    rows: [],
    emptyState: { empty: 'state' },
  },
  'renders Table with children': {
    columns: columnsFixtures,
    rows: rowsFixtures,
    children: 'some children',
  },
  'renders Table with body': {
    columns: columnsFixtures,
    rows: rowsFixtures,
    bodyMessage: 'some body message',
  },
  'renders Table with pagination': {
    columns: columnsFixtures,
    rows: rowsFixtures,
    children: 'some children',
    itemCount: 2,
    pagination: { page: 1, perPage: 20 },
  },
};

describe('Table', () => testComponentSnapshotsWithFixtures(Table, fixtures));
