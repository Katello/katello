import thunk from 'redux-thunk';
import Immutable from 'seamless-immutable';
import configureMockStore from 'redux-mock-store';
import { mockRequest, mockReset } from '../../../mockRequest';
import {
  requestSuccessResponse,
  getSuccessActions,
  getFailureActions,
} from './organizations.fixtures';

import { loadOrganization } from '../OrganizationActions';

const mockStore = configureMockStore([thunk]);
const store = mockStore({ organization: Immutable({}) });

beforeEach(() => {
  store.clearActions();
  mockReset();
});

describe('organization actions', () => {
  it('creates GET_ORGANIZATION_REQUEST and then fails with 422', async () => {
    mockRequest({
      url: '/katello/api/v2/organizations/1',
      status: 422,
    });
    await store.dispatch(loadOrganization());
    expect(store.getActions()).toEqual(getFailureActions);
  });

  it('creates GET_ORGANIZATION_REQUEST and ends with success', async () => {
    mockRequest({
      url: '/katello/api/v2/organizations/1',
      response: requestSuccessResponse,
    });
    await store.dispatch(loadOrganization());
    expect(store.getActions()).toEqual(getSuccessActions);
  });
});
