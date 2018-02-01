/* eslint-disable import/no-extraneous-dependencies */
import React, { Component } from 'react';
import { connect } from 'react-redux';
import { DropdownButton, MenuItem } from 'patternfly-react';
import PropTypes from 'prop-types';

import '../index.scss';
import TypeAhead from '../../../move_to_pf/TypeAhead/TypeAhead';
import { stringIncludes } from '../helpers';
import { loadEnabledRepos } from '../../../redux/actions/RedHatRepositories/enabled';
import { loadRepositorySets } from '../../../redux/actions/RedHatRepositories/sets';
import api from '../../../services/api';

class Search extends Component {
  constructor(props) {
    super(props);
    this.dropDownItems = [
      {
        key: 'available',
        endpoint: 'repository_sets',
        title: 'Available',
      },
      {
        key: 'enabled',
        endpoint: 'enabled_repositories',
        title: 'Enabled',
      },
      {
        key: 'both',
        endpoint: false,
        title: 'Both',
      },
    ];
    this.state = { items: [], searchList: this.dropDownItems[0] };
    this.onInputUpdate = this.onInputUpdate.bind(this);
    this.onSearch = this.onSearch.bind(this);
    this.getAutoCompleteEndpointParams = this.getAutoCompleteEndpointParams.bind(this);
  }

  componentDidMount() {
    this.onInputUpdate();
  }

  onInputUpdate(searchTerm = '') {
    const items = this.state.items.filter(({ text }) => stringIncludes(text, searchTerm));

    if (items.length !== this.state.items.length) {
      this.setState({ items });
    }

    const autoCompleteParams = this.getAutoCompleteEndpointParams(searchTerm);

    api.get(...autoCompleteParams).then(({ data }) => {
      this.setState({
        items: data.filter(({ error }) => !error).map(({ label }) => ({
          text: label.trim(),
        })),
      });
    });
  }

  onSearch(search) {
    const searchList = this.state.searchList.key;

    if (['both', 'available'].includes(searchList)) {
      this.props.loadRepositorySets({ search });
    }

    if (['both', 'enabled'].includes(searchList)) {
      this.props.loadEnabledRepos({ search });
    }
  }

  getAutoCompleteEndpointParams(search) {
    const endpoint = '/repository_sets/auto_complete_search';

    const params = {
      organization_id: 1,
      search,
    };

    if (this.state.searchList.key === 'enabled') {
      params.enabled = true;
    }

    const headers = {};

    return [endpoint, headers, params];
  }

  render() {
    return (
      <div style={{ display: 'flex' }}>
        <DropdownButton title={this.state.searchList.title} id="search-list-select">
          {this.dropDownItems
            .filter(({ key }) => key !== this.state.searchList.key)
            .map(({ key, title, ...rest }) => (
              <MenuItem
                key={key}
                onClick={() => {
                  this.setState({ searchList: { key, title, ...rest } });
                }}
              >
                {title}
              </MenuItem>
            ))}
        </DropdownButton>
        <TypeAhead
          items={this.state.items}
          onInputUpdate={this.onInputUpdate}
          onSearch={this.onSearch}
        />
      </div>
    );
  }
}

Search.propTypes = {
  loadEnabledRepos: PropTypes.func.isRequired,
  loadRepositorySets: PropTypes.func.isRequired,
};

export default connect(null, {
  loadEnabledRepos,
  loadRepositorySets,
})(Search);
