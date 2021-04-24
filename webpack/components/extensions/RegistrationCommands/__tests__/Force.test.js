import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';
import Force from '../fields/Force';

const fixtures = {
  renders: { value: false, isLoading: false, onChange: () => {} },
};

describe('Force', () =>
  testComponentSnapshotsWithFixtures(Force, fixtures));
