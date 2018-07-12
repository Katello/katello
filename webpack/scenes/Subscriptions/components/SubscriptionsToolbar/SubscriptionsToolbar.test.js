import { testComponentSnapshotsWithFixtures } from '../../../../move_to_pf/test-utils/testHelpers';

import SubscriptionsToolbar from './SubscriptionsToolbar';

const createRequiredProps = () => ({
  onSearch: jest.fn(),
  getAutoCompleteParams: jest.fn(),
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
};

describe('SubscriptionsToolbar', () => testComponentSnapshotsWithFixtures(SubscriptionsToolbar, fixtures));
