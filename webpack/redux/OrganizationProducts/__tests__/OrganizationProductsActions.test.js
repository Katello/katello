import { testActionSnapshotWithFixtures } from 'react-redux-test-utils';
import api, { orgId } from '../../../services/api';
import { apiError } from '../../../utils/helpers';

import { loadOrganizationProducts } from '../OrganizationProductsActions';

const params = {
  search: 'some-search',
};

jest.mock('../../../services/api');
jest.mock('../../../utils/helpers');

const fixtures = {
  'should load organization products and success': () => async (dispatch) => {
    await loadOrganizationProducts(params)(dispatch);

    expect(api.get.mock.calls).toMatchSnapshot('API get call');
    expect(apiError).not.toHaveBeenCalled();
  },
  'should load organization products and fail': () => (dispatch) => {
    api.get.mockImplementation(async () => {
      throw new Error('some-error');
    });

    return loadOrganizationProducts(params)(dispatch);
  },
};

describe('OrganizationProducts actions', () => {
  beforeEach(() => {
    orgId.mockImplementation(() => 'some-org-id');
    api.get.mockImplementation(async () => ({
      data: {
        results: [{ id: 'some-id' }],
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
