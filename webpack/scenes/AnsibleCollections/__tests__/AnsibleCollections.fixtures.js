import Immutable from 'seamless-immutable';
import { initialApiState } from '../../../services/api';
import { toastErrorAction, failureAction } from '../../../services/api/testHelpers';

export const initialState = initialApiState;

export const loadingState = Immutable({
  ...initialState,
  loading: true,
});

export const results = [
  {
    id: 1,
    name: 'base',
    namespace: 'devoperate',
    version: '0.1.0',
    checksum: 'e02dfd6f7343cd977db1cecbba000f54389cf6193ff677d8deb7c8ad13bccde6',
  },
  {
    id: 2,
    name: 'collection_demo',
    namespace: 'newswangerd',
    version: '1.0.5',
    checksum: '60bf94a30d3b7015c7cdc2a99f0a440f68f71cb56c934ba3787e52a6061fa2d5',
  },
];

export const successState = {
  itemCount: NaN,
  loading: false,
  pagination: { page: NaN, perPage: 20 },
  results,
};

export const ansibleCollectionsErrorActions = [
  {
    type: 'ANSIBLE_COLLECTIONS_REQUEST',
  },
  failureAction('ANSIBLE_COLLECTIONS_ERROR', 'Request failed with status code 500'),
  toastErrorAction('Request failed with status code 500'),
];

export const ansibleCollectionsSuccessActions = [
  {
    type: 'ANSIBLE_COLLECTIONS_REQUEST',
  },
  {
    type: 'ANSIBLE_COLLECTIONS_SUCCESS',
    response: results,
  },
];
