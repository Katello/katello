import thunk from 'redux-thunk';
import Immutable from 'seamless-immutable';
import configureMockStore from 'redux-mock-store';
import { mockRequest, mockErrorRequest, mockReset } from '../../../../mockRequest';
import { loadSubscriptionDetails } from '../SubscriptionDetailActions';
import {
  loadSubscriptionsDetailsSuccessActions,
  loadSubscriptionsDetailsFailureActions,
  subDetails,
} from './subscriptionDetails.fixtures';

const mockStore = configureMockStore([thunk]);
const store = mockStore({ subscriptionDetails: Immutable({}) });
const endpoint = /\/organizations\/\d+\/subscriptions\/\d+/;

afterEach(() => {
  store.clearActions();
  mockReset();
});

describe('subscription detail actions', () => {
  describe('loadSubscriptionDetails', () => {
    it(
      'creates SUBSCRIPTION_DETAILS_REQUEST and then fails with 500',
      async () => {
        mockErrorRequest({
          url: endpoint,
        });
        await store.dispatch(loadSubscriptionDetails(1));
        expect(store.getActions())
          .toEqual(loadSubscriptionsDetailsFailureActions);
      },
    );
    it(
      'creates SUBSCRIPTION_DETAILS_SUCCESS and ends with success',
      async () => {
        mockRequest({
          url: endpoint,
          response: subDetails,
        });
        await store.dispatch(loadSubscriptionDetails(1));
        expect(store.getActions())
          .toEqual(loadSubscriptionsDetailsSuccessActions);
      },
    );
  });
});
