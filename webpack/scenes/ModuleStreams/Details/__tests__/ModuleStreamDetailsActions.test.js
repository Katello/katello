import { testActionSnapshotWithFixtures } from '../../../../move_to_pf/test-utils/testHelpers';
import api from '../../../../services/api';
import { apiError } from '../../../../move_to_foreman/common/helpers';
import { loadModuleStreamDetails } from '../ModuleStreamDetailsActions';
import { details } from './moduleStreamDetails.fixtures';

jest.mock('../../../../services/api');
jest.mock('../../../../move_to_foreman/common/helpers');

const fixtures = {
  'should load module stream details on success': {
    action: () => loadModuleStreamDetails('1'),
    test: () => {
      expect(api.get.mock.calls).toMatchSnapshot();
      expect(apiError).not.toHaveBeenCalled();
    },
  },
  'should load fail on bad api call': () => (dispatch) => {
    api.get.mockImplementation(async () => {
      throw new Error('some-error');
    });

    return loadModuleStreamDetails('1')(dispatch);
  },
};

describe('Module stream details actions', () => {
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
