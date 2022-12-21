/* eslint-disable import/no-extraneous-dependencies */
import React, { Component } from 'react';
import { DropdownButton, MenuItem } from 'patternfly-react';
import PropTypes from 'prop-types';
import SearchBar from 'foremanReact/components/SearchBar';
import { translate as __ } from 'foremanReact/common/I18n';
import '../index.scss';
import { orgId } from '../../../services/api';

class RepositorySearch extends Component {
  constructor(props) {
    super(props);
    this.dropDownItems = [
      {
        key: 'available',
        endpoint: 'repository_sets',
        title: __('Available'),
      },
      {
        key: 'enabled',
        endpoint: 'enabled_repositories',
        title: __('Enabled'),
      },
      {
        key: 'both',
        endpoint: false,
        title: __('Both'),
      },
    ];
    this.state = { searchList: this.dropDownItems[0] };
    this.onSearch = this.onSearch.bind(this);
  }

  onSearch(search) {
    this.props.onSearch(search);
  }

  onSelectSearchList(searchList) {
    this.setState({ searchList });
    this.props.onSelectSearchList(searchList.key);
  }

  getAutoCompleteEndpoint() {
    let endpoint = '';
    if (this.state.searchList.key === 'enabled') {
      endpoint = '/katello/api/v2/repositories/auto_complete_search';
    } else if (this.state.searchList.key === 'available') {
      endpoint = '/katello/api/v2/repository_sets/auto_complete_search';
    }

    return endpoint;
  }

  autocompleteQueryParams() {
    const params = { organization_id: orgId() };
    if (this.state.searchList.key === 'enabled') {
      params.enabled = true;
    }

    return params;
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
                onClick={() =>
                  this.onSelectSearchList({ key, title, ...rest })
                }
              >
                {title}
              </MenuItem>
            ))}
        </DropdownButton>
        <SearchBar
          data={{
            autocomplete: {
              url: this.getAutoCompleteEndpoint(),
              apiParams: this.autocompleteQueryParams(),
            },
            bookmarks: {},
          }}
          onSearch={this.onSearch}
        />
      </div>
    );
  }
}

RepositorySearch.propTypes = {
  onSearch: PropTypes.func.isRequired,
  onSelectSearchList: PropTypes.func.isRequired,
};

export default RepositorySearch;
