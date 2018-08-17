import thunk from 'redux-thunk';
import Immutable from 'seamless-immutable';
import configureMockStore from 'redux-mock-store';
import { mockRequest, mockErrorRequest, mockReset } from '../../../mockRequest';
import { getModuleStreams } from '../ModuleStreamsActions';
import {
  moduleStreamsFailureActions,
  moduleStreamsSuccessActions,
  results,
} from './moduleStreams.fixtures';

const mockStore = configureMockStore([thunk]);
const store = mockStore({ moduleStreams: Immutable({}) });
const endpoint = '/katello/api/v2/module_streams';

afterEach(() => {
  store.clearActions();
  mockReset();
});

describe('module stream actions', () => {
  describe('getModuleStreams', () => {
    it(
      'creates MODULE_STREAMS_REQUEST and then fails with 500 on bad request',
      () => {
        mockErrorRequest({
          url: endpoint,
        });
        return store.dispatch(getModuleStreams())
          .then(() => expect(store.getActions())
            .toEqual(moduleStreamsFailureActions));
      },
    );

    it(
      'creates MODULE_STREAMS_REQUEST and then return successfully',
      () => {
        mockRequest({
          url: endpoint,
          response: results,
        });
        return store.dispatch(getModuleStreams())
          .then(() => expect(store.getActions())
            .toEqual(moduleStreamsSuccessActions));
      },
    );
  });
});

