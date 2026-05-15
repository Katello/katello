/* eslint-disable import/no-extraneous-dependencies */
import React, { useState, useEffect, useCallback } from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';

import {
  selectOrganizationProducts,
  selectOrganizationProductsLoading,
} from '../../../redux/OrganizationProducts/OrganizationProductsSelectors';
import { loadOrganizationProducts as loadOrganizationProductsAction }
  from '../../../redux/OrganizationProducts/OrganizationProductsActions';

import { loadEnabledRepos as loadEnabledReposAction } from '../../../redux/actions/RedHatRepositories/enabled';
import { loadRepositorySets as loadRepositorySetsAction } from '../../../redux/actions/RedHatRepositories/sets';

import Search from './Search';
import MultiSelect from '../../../components/MultiSelect/index';

const filterOptions = [
  { value: 'rpm', label: __('RPM') },
  { value: 'sourceRpm', label: __('Source RPM') },
  { value: 'debugRpm', label: __('Debug RPM') },
  { value: 'kickstart', label: __('Kickstart') },
  { value: 'beta', label: __('Beta') },
  { value: 'other', label: __('Other') },
];

const SearchBar = ({
  loadOrganizationProducts,
  loadEnabledRepos,
  loadRepositorySets,
  organizationProducts,
  organizationProductsLoading,
  enabledRepositories,
  repositorySets,
}) => {
  const [query, setQuery] = useState('');
  const [searchList, setSearchList] = useState('available');
  const [filters, setFilters] = useState(['rpm']);
  const [products, setProducts] = useState([]);

  useEffect(() => {
    // load all products until we use filtering and pagination
    loadOrganizationProducts({ per_page: 1000, redhat_only: true });
  }, [loadOrganizationProducts]);

  const reloadRepos = useCallback((repoSetsSearch, enabledSearch) => {
    if (repoSetsSearch !== null) {
      const setsParams = {
        perPage: repositorySets.pagination.perPage,
        search: repoSetsSearch,
      };
      loadRepositorySets(setsParams);
    }

    if (enabledSearch !== null) {
      const enabledParams = {
        perPage: enabledRepositories.pagination.perPage,
        search: enabledSearch,
      };
      loadEnabledRepos(enabledParams);
    }
  }, [loadRepositorySets, loadEnabledRepos, repositorySets.pagination.perPage,
    enabledRepositories.pagination.perPage]);

  const updateSearch = useCallback((stateUpdate = {}) => {
    const newState = {
      query,
      searchList,
      filters,
      products,
      ...stateUpdate,
    };

    // Update local state
    if (stateUpdate.query !== undefined) setQuery(stateUpdate.query);
    if (stateUpdate.searchList !== undefined) setSearchList(stateUpdate.searchList);
    if (stateUpdate.filters !== undefined) setFilters(stateUpdate.filters);
    if (stateUpdate.products !== undefined) setProducts(stateUpdate.products);

    const clearSearch = stateUpdate.searchList ? {} : null;

    if (newState.searchList === 'available') {
      reloadRepos(newState, clearSearch);
    } else if (newState.searchList === 'enabled') {
      reloadRepos(clearSearch, newState);
    } else {
      reloadRepos(newState, newState);
    }
  }, [query, searchList, filters, products, reloadRepos]);

  const handleSearch = useCallback((searchQuery) => {
    updateSearch({ query: searchQuery });
  }, [updateSearch]);

  const handleSelectSearchList = useCallback((selectedSearchList) => {
    updateSearch({ searchList: selectedSearchList });
  }, [updateSearch]);

  const handleSelectFilterType = useCallback((selectedFilters) => {
    updateSearch({ filters: selectedFilters });
  }, [updateSearch]);

  const handleSelectProduct = useCallback((selectedProducts) => {
    updateSearch({ products: selectedProducts });
  }, [updateSearch]);

  return (
    <div className="toolbar-pf-actions">
      <div className="search-bar-row">
        <Search onSearch={handleSearch} onSelectSearchList={handleSelectSearchList} />
      </div>

      <div className="search-bar-row search-bar-selects-row">
        <MultiSelect
          className="product-select"
          ouiaId="filter-by-product"
          options={organizationProducts.map(product => ({
            value: product.id, label: product.name,
          }))}
          defaultValues={[]}
          noneSelectedText={__('Filter by Product')}
          maxItemsCountForFullLabel={2}
          onChange={handleSelectProduct}
          isLoading={organizationProductsLoading}
          searchable
        />
        <MultiSelect
          ouiaId="filter-by-type"
          options={filterOptions}
          defaultValues={['rpm']}
          noneSelectedText={__('Filter by type')}
          onChange={handleSelectFilterType}
        />
      </div>
    </div>
  );
};

SearchBar.propTypes = {
  loadEnabledRepos: PropTypes.func.isRequired,
  loadRepositorySets: PropTypes.func.isRequired,
  loadOrganizationProducts: PropTypes.func.isRequired,
  organizationProducts: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.oneOfType([PropTypes.number, PropTypes.string]),
    name: PropTypes.string,
  })).isRequired,
  organizationProductsLoading: PropTypes.bool.isRequired,
  enabledRepositories: PropTypes.shape({
    pagination: PropTypes.shape({
      perPage: PropTypes.number,
    }),
  }).isRequired,
  repositorySets: PropTypes.shape({
    pagination: PropTypes.shape({
      perPage: PropTypes.number,
    }),
  }).isRequired,
};

const mapStateToProps = (state) => {
  const { katello: { redHatRepositories: { enabled, sets } } } = state;

  return {
    enabledRepositories: enabled,
    repositorySets: sets,
    organizationProducts: selectOrganizationProducts(state),
    organizationProductsLoading: selectOrganizationProductsLoading(state),
  };
};

export default connect(mapStateToProps, {
  loadEnabledRepos: loadEnabledReposAction,
  loadRepositorySets: loadRepositorySetsAction,
  loadOrganizationProducts: loadOrganizationProductsAction,
})(SearchBar);
