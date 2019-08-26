import { testActionSnapshotWithFixtures } from 'react-redux-test-utils';
import api from '../../../../services/api';
import { apiError } from '../../../../move_to_foreman/common/helpers';
import { getAnsibleCollectionDetails } from '../AnsibleCollectionDetailsActions';
import { details } from './AnsibleCollectionDetails.fixtures';

jest.mock('../../../../services/api');
jest.mock('../../../../move_to_foreman/common/helpers');

const fixtures = {
  'should load ansible collection details on success': () => async (dispatch) => {
    await getAnsibleCollectionDetails('1')(dispatch);

    expect(api.get.mock.calls).toMatchSnapshot('API get call');
    expect(apiError).not.toHaveBeenCalled();
  },
  'should load fail on bad api call': () => (dispatch) => {
    api.get.mockImplementation(async () => {
      throw new Error('some-error');
    });

    return getAnsibleCollectionDetails('1')(dispatch);
  },
};

describe('Ansible Collection details actions', () => {
  beforeEach(() => {
    api.get.mockImplementation(async () => ({
      data: {
        results: details,
      },
    }));
  });
  afterEach(() => {
    jest.resetAllMocks();
    jest.restoreAllMocks();
    jest.resetModules();
  });

  testActionSnapshotWithFixtures(fixtures);
});
