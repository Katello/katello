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
    manifestActionsDisabled: true,
    manifestActionsDisabledReason: 'some reason for manifest',
  },
  'renders SubscriptionsToolbar with disabled delete button': {
    ...createRequiredProps(),
    deleteButtonDisabled: true,
    deleteButtonDisabledReason: 'some reason for delete',
  },
  'renders SubscriptionsToolbar with disabled add button': {
    ...createRequiredProps(),
    addButtonDisabled: true,
    manifestActionsDisabledReason: 'some reason for manifest',
  },
};

describe('SubscriptionsToolbar', () => testComponentSnapshotsWithFixtures(SubscriptionsToolbar, fixtures));
