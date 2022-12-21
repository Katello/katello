import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';
import SubscriptionsToolbar from './SubscriptionsToolbar';

const createRequiredProps = () => ({
  onSearch: jest.fn(),
  updateSearchQuery: jest.fn(),
});
const fixtures = {
  'renders SubscriptionsToolbar': {
    ...createRequiredProps(),
  },
  'renders SubscriptionsToolbar with disabled manifest actions': {
    ...createRequiredProps(),
    disableManifestActions: true,
    disableManifestReason: 'some reason for manifest',
  },
  'renders SubscriptionsToolbar with disabled delete button': {
    ...createRequiredProps(),
    disableDeleteButton: true,
    disableDeleteReason: 'some reason for delete',
  },
  'renders SubscriptionsToolbar with disabled add button': {
    ...createRequiredProps(),
    disableAddButton: true,
    disableManifestReason: 'some reason for manifest',
  },
  'renders SubscriptionsToolbar with table columns': {
    ...createRequiredProps(),
    tableColumns: [{
      key: 'col1',
      label: 'Col 1',
      value: true,
    }, {
      key: 'col2',
      label: 'Col 2',
      value: false,
    }, {
      key: 'col2',
      label: 'Col 2',
      value: false,
    }],
  },
};

describe('SubscriptionsToolbar', () =>
  testComponentSnapshotsWithFixtures(SubscriptionsToolbar, fixtures));
