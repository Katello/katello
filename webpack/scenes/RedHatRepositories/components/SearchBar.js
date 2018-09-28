/* eslint-disable import/no-extraneous-dependencies */
import React, { Component } from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';

import { Button } from 'patternfly-react';
import { Form, FormGroup } from 'react-bootstrap';

import { loadEnabledRepos } from '../../../redux/actions/RedHatRepositories/enabled';
import { loadRepositorySets } from '../../../redux/actions/RedHatRepositories/sets';

import api from '../../../services/api';
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

  onSearch(query) {
    this.updateSearch({ query });
  }

  onSelectSearchList(searchList) {
    this.updateSearch({ searchList });
  }

  onSelectFilterType(filters) {
    this.updateSearch({ filters });
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
    const { repoParams } = this.props;

    return (
      <Form className="toolbar-pf-actions">
        <FormGroup className="toolbar-pf-filter">
          <Search onSearch={this.onSearch} onSelectSearchList={this.onSelectSearchList} />
        </FormGroup>

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

        <FormGroup>
          <Button
            className="export-csv-button"
            onClick={() => { api.open('/repositories.csv', repoParams); }}
          >
            {__('Export Enabled as CSV')}
          </Button>
        </FormGroup>
      </Form>
    );
  }
}

SearchBar.propTypes = {
  loadEnabledRepos: PropTypes.func.isRequired,
  loadRepositorySets: PropTypes.func.isRequired,
  repoParams: PropTypes.shape({}).isRequired,
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

const mapStateToProps = ({ katello: { redHatRepositories: { enabled, sets } } }) => ({
  enabledRepositories: enabled,
  repositorySets: sets,
});

export default connect(mapStateToProps, {
  loadEnabledRepos,
  loadRepositorySets,
})(SearchBar);
