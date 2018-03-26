import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import thunk from 'redux-thunk';
import Immutable from 'seamless-immutable';
import configureMockStore from 'redux-mock-store';
import { mockRequest, mockReset } from '../../../mockRequest';
import {
  requestSuccessResponse,
  getSuccessActions,
  getFailureActions,
  saveSuccessActions,
  saveFailureActions,
} from './organizations.fixtures';

import { loadOrganization, saveOrganization } from '../OrganizationActions';

const mockStore = configureMockStore([thunk]);
const store = mockStore({ organization: Immutable({}) });

beforeEach(() => {
  store.clearActions();
  mockReset();
});

describe('organization actions', () => {
  it('creates GET_ORGANIZATION_REQUEST and then fails with 422', () => {
    mockRequest({
      url: '/katello/api/v2/organizations/1',
      status: 422,
    });
    return store.dispatch(loadOrganization())
      .then(() => expect(store.getActions()).toEqual(getFailureActions));
  });

  it('creates GET_ORGANIZATION_REQUEST and ends with success', () => {
    mockRequest({
      url: '/katello/api/v2/organizations/1',
      response: requestSuccessResponse,
    });
    return store.dispatch(loadOrganization())
      .then(() => expect(store.getActions()).toEqual(getSuccessActions));
  });

  it('creates SAVE_ORGANIZATION_REQUEST and then fails with 422', () => {
    const mock = new MockAdapter(axios);
    mock.onPut('/katello/api/v2/organizations/1').reply(422);

    return store.dispatch(saveOrganization())
      .then(() => expect(store.getActions()).toEqual(saveFailureActions));
  });

  it('creates SAVE_ORGANIZATION_REQUEST and ends with success', () => {
    const mock = new MockAdapter(axios);
    mock.onPut('/katello/api/v2/organizations/1').reply(200, requestSuccessResponse);

    return store.dispatch(saveOrganization())
      .then(() => expect(store.getActions()).toEqual(saveSuccessActions));
  });
});
