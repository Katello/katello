import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';
import IgnoreSubmanErrors from '../fields/IgnoreSubmanErrors';

const fixtures = {
  renders: { value: false, isLoading: false, onChange: () => {} },
};

describe('IgnoreSubmanErrors', () =>
  testComponentSnapshotsWithFixtures(IgnoreSubmanErrors, fixtures));
