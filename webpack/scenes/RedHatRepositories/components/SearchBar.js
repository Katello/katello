/* eslint-disable import/no-extraneous-dependencies */
import React, { Component } from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';

import { Form, FormGroup } from 'react-bootstrap';
import { translate as __ } from 'foremanReact/common/I18n';

import { selectOrganizationProducts } from '../../../redux/OrganizationProducts/OrganizationProductsSelectors';
import { loadOrganizationProducts } from '../../../redux/OrganizationProducts/OrganizationProductsActions';

import { loadEnabledRepos } from '../../../redux/actions/RedHatRepositories/enabled';
import { loadRepositorySets } from '../../../redux/actions/RedHatRepositories/sets';

import Search from './Search';
import MultiSelect from '../../../components/MultiSelect/index';

const filterOptions = [
  { value: 'rpm', label: __('RPM') },
  { value: 'sourceRpm', label: __('Source RPM') },
  { value: 'debugRpm', label: __('Debug RPM') },
  { value: 'kickstart', label: __('Kickstart') },
  { value: 'ostree', label: __('OSTree') },
  { value: 'beta', label: __('Beta') },
  { value: 'other', label: __('Other') },
];

class SearchBar extends Component {
  constructor(props) {
    super(props);

    this.state = {
      query: '',
      searchList: 'available',
      filters: ['rpm'],
    };

    this.onSearch = this.onSearch.bind(this);
    this.onSelectSearchList = this.onSelectSearchList.bind(this);
  }

  componentDidMount() {
    // load all products until we use filtering and pagination
    this.props.loadOrganizationProducts({ per_page: 1000, redhat_only: true });
  }

  onSearch(query) {
    this.updateSearch({ query });
  }

  onSelectSearchList(searchList) {
    this.updateSearch({ searchList });
  }

  onSelectFilterType(filters) {
    this.updateSearch({ filters });
  }

  onSelectProduct(products) {
    this.updateSearch({ products });
  }

  updateSearch(stateUpdate = {}) {
    const newState = {
      ...this.state,
      ...stateUpdate,
    };
    this.setState(stateUpdate);

    const clearSearch = stateUpdate.searchList ? {} : null;

    if (newState.searchList === 'available') {
      this.reloadRepos(newState, clearSearch);
    } else if (newState.searchList === 'enabled') {
      this.reloadRepos(clearSearch, newState);
    } else {
      this.reloadRepos(newState, newState);
    }
  }

  reloadRepos(repoSetsSearch, enabledSearch) {
    if (repoSetsSearch !== null) {
      const setsParams = {
        perPage: this.props.repositorySets.pagination.perPage,
        search: repoSetsSearch,
      };
      this.props.loadRepositorySets(setsParams);
    }

    if (enabledSearch !== null) {
      const enabledParams = {
        perPage: this.props.enabledRepositories.pagination.perPage,
        search: enabledSearch,
      };
      this.props.loadEnabledRepos(enabledParams);
    }
  }

  render() {
    const { organizationProducts } = this.props;

    const getMultiSelectValuesFromEvent = e => [...e.target.options]
      .filter(({ selected }) => selected)
      .map(({ value }) => value);

    return (
      <Form className="toolbar-pf-actions">
        <div className="search-bar-row">
          <FormGroup className="toolbar-pf-filter">
            <Search onSearch={this.onSearch} onSelectSearchList={this.onSelectSearchList} />
          </FormGroup>
        </div>

        <div className="search-bar-row search-bar-selects-row">
          <MultiSelect
            className="product-select"
            value="product"
            options={organizationProducts.map(product => ({
              value: product.id, label: product.name,
            }))}
            defaultValues={[]}
            noneSelectedText={__('Filter by Product')}
            maxItemsCountForFullLabel={2}
            onChange={(e) => {
              const values = getMultiSelectValuesFromEvent(e);
              this.onSelectProduct(values);
            }}
          />
          <MultiSelect
            value={this.state.filters}
            options={filterOptions}
            defaultValues={['rpm']}
            noneSelectedText={__('Filter by type')}
            onChange={(e) => {
              const values = [...e.target.options]
                .filter(({ selected }) => selected)
                .map(({ value }) => value);
              this.onSelectFilterType(values);
            }}
          />
        </div>
      </Form>
    );
  }
}

SearchBar.propTypes = {
  loadEnabledRepos: PropTypes.func.isRequired,
  loadRepositorySets: PropTypes.func.isRequired,
  loadOrganizationProducts: PropTypes.func.isRequired,
  organizationProducts: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.oneOfType([PropTypes.number, PropTypes.string]),
    name: PropTypes.string,
  })).isRequired,
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
  };
};

export default connect(mapStateToProps, {
  loadEnabledRepos,
  loadRepositorySets,
  loadOrganizationProducts,
})(SearchBar);
