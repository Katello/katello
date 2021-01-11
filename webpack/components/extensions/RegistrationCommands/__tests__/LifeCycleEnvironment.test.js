import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';
import LifeCycleEnvironment from '../fields/LifeCycleEnvironment';

const fixtures = {
  renders: {
    pluginValues: {}, isLoading: false, onChange: () => {}, hostGroupEnvironment: '', lifeCycleEnvironments: [],
  },
};

describe('LifeCycleEnvironment', () =>
  testComponentSnapshotsWithFixtures(LifeCycleEnvironment, fixtures));
