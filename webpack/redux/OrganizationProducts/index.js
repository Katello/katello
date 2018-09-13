import { ORGANIZATION_PRODUCTS_KEY } from './OrganizationProductsConstants';
import reducer from './OrganizationProductsReducer';
import * as organizationProductsActions from './OrganizationProductsActions';
import * as organizationProductsSelectors from './OrganizationProductsSelectors';

// export actions
export const actions = { ...organizationProductsActions };

// export selectors
export const selectors = { ...organizationProductsSelectors };

// export reducers
export const reducers = { [ORGANIZATION_PRODUCTS_KEY]: reducer };
