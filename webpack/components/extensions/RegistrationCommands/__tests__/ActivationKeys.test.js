import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';
import ActivationKeys from '../fields/ActivationKeys';

const fixtures = {
  renders: {
    activationKeys: [],
    selectedKeys: [],
    hostGroupActivationKeys: [],
    hostGroupId: '',
    pluginValues: {},
    onChange: () => {},
    handleInvalidField: () => {},
    isLoading: false,
  },
};

describe('ActivationKeys', () =>
  testComponentSnapshotsWithFixtures(ActivationKeys, fixtures));
