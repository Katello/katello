import axios from '@theforeman/vendor/axios';
import MockAdapter from 'axios-mock-adapter';
import configureMockStore from 'redux-mock-store';
import thunk from '@theforeman/vendor/redux-thunk';
import Immutable from '@theforeman/vendor/seamless-immutable';
import {
  successResponse,
  getSuccessActions,
  getFailureActions,
} from './settings.fixtures';

import { loadSetting } from '../SettingsActions';

const mockStore = configureMockStore([thunk]);
const store = mockStore({ subscriptions: Immutable({}) });
const mockApi = new MockAdapter(axios);

afterEach(() => {
  store.clearActions();
  mockApi.reset();
});

describe('load setting actions  ', () => {
  const url = '/api/v2/settings/test_setting';

  describe('creates GET_SETTING_REQUEST', () => {
    it('and then fails with 422', () => {
      mockApi.onGet(url).reply(422);

      return store.dispatch(loadSetting('test_setting'))
        .then(() => expect(store.getActions()).toEqual(getFailureActions));
    });

    it('and ends with success', () => {
      mockApi.onGet(url).reply(200, successResponse);

      return store.dispatch(loadSetting('test_setting'))
        .then(() => expect(store.getActions()).toEqual(getSuccessActions));
    });
  });
});
