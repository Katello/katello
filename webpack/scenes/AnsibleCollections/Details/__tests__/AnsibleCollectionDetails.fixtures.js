import Immutable from 'seamless-immutable';
import { initialApiState } from '../../../../services/api';

export const initialState = initialApiState;

export const details = {
  id: 2,
  name: 'collection_demo',
  namespace: 'newswangerd',
  version: '1.0.5',
  checksum: '60bf94a30d3b7015c7cdc2a99f0a440f68f71cb56c934ba3787e52a6061fa2d5',
  repositories: [
    {
      id: 2,
      name: 'ans_collection',
      product_id: 2,
      product_name: 'pulp3_products',
    },
  ],
};

export const loadingState = Immutable({
  ...initialState,
  loading: true,
});
