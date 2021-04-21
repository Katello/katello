import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';
import LifecycleEnvironment from '../fields/LifecycleEnvironment';

const fixtures = {
  renders: {
    pluginValues: {}, isLoading: false, onChange: () => {}, hostGroupEnvironment: '', lifecycleEnvironments: [],
  },
};

describe('LifecycleEnvironment', () =>
  testComponentSnapshotsWithFixtures(LifecycleEnvironment, fixtures));
