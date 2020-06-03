/* eslint-disable import/no-extraneous-dependencies */
import React, { Component } from 'react';
import { ControlLabel } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import TypeAhead from '../TypeAhead';
import api from '../../services/api';
import { stringIncludes } from './helpers';

class Search extends Component {
  constructor(props) {
    super(props);
    this.state = { items: [] };
    this.onInputUpdate = this.onInputUpdate.bind(this);
    this.onSearch = this.onSearch.bind(this);
  }

  componentDidMount() {
    this.onInputUpdate();
  }

  async onInputUpdate(searchTerm = '') {
    const items = this.state.items.filter(({ text }) => stringIncludes(text, searchTerm));

    if (items.length !== this.state.items.length) {
      this.setState({ items });
    }

    const params = this.props.getAutoCompleteParams(searchTerm);
    const autoCompleteParams = [
      params.endpoint,
      params.headers || {},
      params.params || {},
    ];

    if (autoCompleteParams[0] !== '') {
      const { data } = await api.get(...autoCompleteParams);
      this.setState({
        items: data.filter(({ error }) => !error).map(({ label }) => ({
          text: label.trim(),
        })),
      });
    }
  }

  onSearch(search) {
    if (this.props.updateSearchQuery) this.props.updateSearchQuery(search);
    this.props.onSearch(search);
  }

  render() {
    const { initialInputValue, patternfly4 } = this.props;
    return (
      <div>
        <ControlLabel srOnly>{__('Search')}</ControlLabel>
        <TypeAhead
          items={this.state.items}
          onInputUpdate={this.onInputUpdate}
          onSearch={this.onSearch}
          initialInputValue={initialInputValue}
          patternfly4={patternfly4}
        />
      </div>
    );
  }
}

Search.propTypes = {
  /** Callback function when the "Search" button is pressed:
      onSearch(searchQuery)
   */
  onSearch: PropTypes.func.isRequired,
  /** Function returning params for the scoped-search complete api call:
      getAutoCompleteParams(searchQuery)

      Should return a shape { headers, params, endpoint }, e.g.:
      {
        headers: {},
        params: { organization_id, search },
        endpoint: '/subscriptions/auto_complete_search'
      }
  */
  getAutoCompleteParams: PropTypes.func.isRequired,
  updateSearchQuery: PropTypes.func,
  initialInputValue: PropTypes.string,
  patternfly4: PropTypes.bool,
};

Search.defaultProps = {
  updateSearchQuery: undefined,
  initialInputValue: '',
  patternfly4: false,
};
export default Search;
