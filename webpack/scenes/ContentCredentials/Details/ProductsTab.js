/* eslint-disable @theforeman/rules/require-ouiaid */
import React, { useState, useMemo } from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Table, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import {
  Card,
  CardBody,
  TextInput,
  Toolbar,
  ToolbarContent,
  ToolbarItem,
} from '@patternfly/react-core';

import EmptyStateMessage from '../../../components/Table/EmptyStateMessage';

const ProductsTab = ({ details }) => {
  const [filterText, setFilterText] = useState('');

  const {
    gpg_key_products: gpgKeyProducts = [],
    ssl_ca_products: sslCaProducts = [],
    ssl_client_products: sslClientProducts = [],
    ssl_key_products: sslKeyProducts = [],
  } = details;

  // Combine all products with their usage type
  const allProducts = useMemo(() => [
    ...gpgKeyProducts.map(product => ({ ...product, used_as: __('GPG Key') })),
    ...sslCaProducts.map(product => ({ ...product, used_as: __('SSL CA Certificate') })),
    ...sslClientProducts.map(product => ({ ...product, used_as: __('SSL Client Certificate') })),
    ...sslKeyProducts.map(product => ({ ...product, used_as: __('SSL Client Key') })),
  ], [gpgKeyProducts, sslCaProducts, sslClientProducts, sslKeyProducts]);

  // Filter products based on search text
  const filteredProducts = useMemo(() => {
    if (!filterText.trim()) {
      return allProducts;
    }

    const searchTerm = filterText.toLowerCase();
    return allProducts.filter(product =>
      product.name?.toLowerCase().includes(searchTerm) ||
      product.used_as?.toLowerCase().includes(searchTerm));
  }, [allProducts, filterText]);

  if (allProducts.length === 0) {
    return (
      <Card ouiaId="products-empty-state-card">
        <CardBody>
          <EmptyStateMessage
            title={__('No products using this credential')}
            body={__('This content credential is not currently being used by any products.')}
          />
        </CardBody>
      </Card>
    );
  }

  return (
    <>
      <Toolbar ouiaId="products-filter-toolbar">
        <ToolbarContent>
          <ToolbarItem>
            <TextInput
              type="text"
              placeholder={__('Filter...')}
              value={filterText}
              onChange={(_event, value) => setFilterText(value)}
              ouiaId="products-filter-input"
              aria-label={__('Filter products')}
            />
          </ToolbarItem>
        </ToolbarContent>
      </Toolbar>

      {filteredProducts.length === 0 && filterText.trim() ? (
        <Card ouiaId="products-no-results-card">
          <CardBody>
            <EmptyStateMessage
              title={__('No matching products')}
              body={__('No products match your filter criteria.')}
            />
          </CardBody>
        </Card>
      ) : (
        <Table aria-label={__('Products table')} variant="compact" ouiaId="content-credential-products-table">
          <Thead>
            <Tr>
              <Th>{__('Name')}</Th>
              <Th>{__('Used as')}</Th>
            </Tr>
          </Thead>
          <Tbody>
            {filteredProducts.map(product => (
              <Tr key={`${product.id}-${product.used_as}`}>
                <Td>
                  <a href={`/products/${product.id}`}>
                    {product.name}
                  </a>
                </Td>
                <Td>{product.used_as}</Td>
              </Tr>
            ))}
          </Tbody>
        </Table>
      )}
    </>
  );
};

ProductsTab.propTypes = {
  details: PropTypes.shape({
    gpg_key_products: PropTypes.arrayOf(PropTypes.shape({
      id: PropTypes.number,
      name: PropTypes.string,
    })),
    ssl_ca_products: PropTypes.arrayOf(PropTypes.shape({
      id: PropTypes.number,
      name: PropTypes.string,
    })),
    ssl_client_products: PropTypes.arrayOf(PropTypes.shape({
      id: PropTypes.number,
      name: PropTypes.string,
    })),
    ssl_key_products: PropTypes.arrayOf(PropTypes.shape({
      id: PropTypes.number,
      name: PropTypes.string,
    })),
  }).isRequired,
};

export default ProductsTab;
