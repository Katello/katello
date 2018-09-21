import { testActionSnapshotWithFixtures } from '../../../move_to_pf/test-utils/testHelpers';
import api, { orgId } from '../../../services/api';
import { apiError } from '../../../move_to_foreman/common/helpers';

import { loadOrganizationProducts } from '../OrganizationProductsActions';

const params = {
  search: 'some-search',
};

jest.mock('../../../services/api');
jest.mock('../../../move_to_foreman/common/helpers');

const fixtures = {
  'should load organization products and success': {
    action: () => loadOrganizationProducts(params),
    test: () => {
      expect(api.get.mock.calls).toMatchSnapshot();
      expect(apiError).not.toHaveBeenCalled();
    },
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
