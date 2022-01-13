import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';
import AnsibleCollectionDetails from '../AnsibleCollectionDetails';
import { details, loadingState } from './AnsibleCollectionDetails.fixtures';

const mockFunc = jest.fn();

const baseProps = {
  getAnsibleCollectionDetails: mockFunc,
  location: { search: '' },
  history: { push: mockFunc },
  ansibleCollectionDetails: details,
  match: { params: { id: String(details.id) } },
};

const fixtures = {
  'renders with ansible collection provided': {
    ...baseProps,
  },
  'renders with loading state': {
    ...baseProps,
    ansibleCollectionDetails: loadingState,
  },
};

describe('Ansible Collection details page', () => {
  describe('rendering', () => testComponentSnapshotsWithFixtures(AnsibleCollectionDetails, fixtures));
});
