import React, { Component } from 'react';
import PropTypes from 'prop-types';
import qs from 'query-string';
import { translate as __ } from 'foremanReact/common/I18n';
import { orgId } from '../../services/api';
import TableSchema from '../ModuleStreams/ModuleStreamsTableSchema';
import GenericContentPage from '../../components/Content/GenericContentPage';

class ModuleStreamsPage extends Component {
  constructor(props) {
    super(props);

    const queryParams = qs.parse(this.props.location.search);
    this.state = {
      searchQuery: queryParams.search || '',
    };
  }

  componentDidMount() {
    this.props.getModuleStreams({
      search: this.state.searchQuery,
    });
  }

  onPaginationChange = (pagination) => {
    this.props.getModuleStreams({
      ...pagination,
    });
  };

  onSearch = (search) => {
    this.props.getModuleStreams({ search });
  };

  updateSearchQuery = (searchQuery) => {
    this.setState({ searchQuery });
  };

  render() {
    const { moduleStreams } = this.props;
    return (
      <GenericContentPage
        header={__('Module Streams')}
        content={moduleStreams}
        tableSchema={TableSchema}
        onSearch={this.onSearch}
        autocompleteEndpoint="/katello/api/v2/module_streams"
        autocompleteQueryParams={{ organization_id: orgId() }}
        bookmarkController="katello_module_streams"
        updateSearchQuery={this.updateSearchQuery}
        initialInputValue={this.state.searchQuery}
        onPaginationChange={this.onPaginationChange}
      />
    );
  }
}

ModuleStreamsPage.propTypes = {
  location: PropTypes.shape({
    search: PropTypes.oneOfType([
      PropTypes.shape({}),
      PropTypes.string,
    ]),
  }),
  getModuleStreams: PropTypes.func.isRequired,
  moduleStreams: PropTypes.shape({}).isRequired,
};

ModuleStreamsPage.defaultProps = {
  location: { search: '' },
};

export default ModuleStreamsPage;
