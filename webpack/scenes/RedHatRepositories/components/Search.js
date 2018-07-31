/* eslint-disable import/no-extraneous-dependencies */
import React, { Component } from 'react';
import { DropdownButton, MenuItem } from 'patternfly-react';
import PropTypes from 'prop-types';

import '../index.scss';
import Search from '../../../components/Search/index';
import { orgId } from '../../../services/api';

class RepositorySearch extends Component {
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
    this.state = { searchList: this.dropDownItems[0] };
    this.onSearch = this.onSearch.bind(this);
    this.getAutoCompleteParams = this.getAutoCompleteParams.bind(this);
  }

  onSearch(search) {
    this.props.onSearch(search);
  }

  onSelectSearchList(searchList) {
    this.setState({ searchList });
    this.props.onSelectSearchList(searchList.key);
  }

  getAutoCompleteParams(search) {
    const params = {
      organization_id: orgId(),
      search,
    };

    if (this.state.searchList.key === 'enabled') {
      params.enabled = true;
    }

    return {
      endpoint: '/repository_sets/auto_complete_search',
      params,
    };
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
        <Search
          onSearch={this.onSearch}
          getAutoCompleteParams={this.getAutoCompleteParams}
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
