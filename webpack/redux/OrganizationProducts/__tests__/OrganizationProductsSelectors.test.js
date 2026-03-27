import Immutable from 'seamless-immutable';
import { ORGANIZATION_PRODUCTS_KEY } from '../OrganizationProductsConstants';
import { selectOrganizationProductsState, selectOrganizationProducts } from '../OrganizationProductsSelectors';
import organizationProductsData from './organizationProducts.fixtures.json';

describe('OrganizationProducts selectors', () => {
  const stateWithProducts = Immutable({
    katello: {
      [ORGANIZATION_PRODUCTS_KEY]: {
        loading: false,
        error: null,
        results: organizationProductsData.results,
        total: organizationProductsData.total,
        subtotal: organizationProductsData.subtotal,
        page: organizationProductsData.page,
        per_page: organizationProductsData.per_page,
      },
    },
  });

  const emptyState = Immutable({
    katello: {
      [ORGANIZATION_PRODUCTS_KEY]: {
        loading: false,
        error: null,
        results: [],
      },
    },
  });

  describe('selectOrganizationProductsState', () => {
    it('should select the organization products state', () => {
      const result = selectOrganizationProductsState(stateWithProducts);

      expect(result.results).toEqual(organizationProductsData.results);
      expect(result.loading).toBe(false);
      expect(result.error).toBeNull();
    });

    it('should select empty state when no products', () => {
      const result = selectOrganizationProductsState(emptyState);

      expect(result.results).toEqual([]);
      expect(result.loading).toBe(false);
    });
  });

  describe('selectOrganizationProducts', () => {
    it('should select the organization products results array', () => {
      const result = selectOrganizationProducts(stateWithProducts);

      expect(result).toHaveLength(4);
      expect(result[0]).toMatchObject({ name: 'Red Hat Enterprise Linux Server', redhat: true });
      expect(result[1]).toMatchObject({ name: 'Custom Product - PostgreSQL', redhat: false });
    });

    it('should select empty array when no products', () => {
      const result = selectOrganizationProducts(emptyState);

      expect(result).toEqual([]);
      expect(result).toHaveLength(0);
    });

    it('should verify product properties', () => {
      const result = selectOrganizationProducts(stateWithProducts);
      const firstProduct = result[0];

      expect(firstProduct).toMatchObject({
        id: expect.any(Number),
        label: expect.any(String),
        organization_id: expect.any(Number),
        repository_count: expect.any(Number),
        redhat: true,
      });
    });

    it('should handle custom products', () => {
      const result = selectOrganizationProducts(stateWithProducts);
      const customProduct = result[1];

      expect(customProduct).toMatchObject({
        redhat: false,
        sync_plan: null,
      });
    });
  });
});
