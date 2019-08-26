import React, { Component } from 'react';
import PropTypes from 'prop-types';
import qs from 'query-string';
import { translate as __ } from 'foremanReact/common/I18n';
import { orgId } from '../../services/api';
import TableSchema from './AnsibleCollectionsTableSchema';
import ContentPage from '../../components/Content/ContentPage';

class AnsibleCollectionsPage extends Component {
  constructor(props) {
    super(props);

    const queryParams = qs.parse(this.props.location.search);
    this.state = {
      searchQuery: queryParams.search || '',
    };
  }

  componentDidMount() {
    this.props.getAnsibleCollections({
      search: this.state.searchQuery,
    });
  }

  onPaginationChange = (pagination) => {
    this.props.getAnsibleCollections({
      ...pagination,
    });
  };

  onSearch = (search) => {
    this.props.getAnsibleCollections({ search });
  };

  getAutoCompleteParams = search => ({
    endpoint: '/ansible_collections/auto_complete_search',
    params: {
      organization_id: orgId(),
      search,
    },
  });

  updateSearchQuery = (searchQuery) => {
    this.setState({ searchQuery });
  };

  render() {
    const { ansibleCollections } = this.props;
    return (
      <ContentPage
        header={__('Ansible Collections')}
        content={ansibleCollections}
        tableSchema={TableSchema}
        onSearch={this.onSearch}
        getAutoCompleteParams={this.getAutoCompleteParams}
        updateSearchQuery={this.updateSearchQuery}
        initialInputValue={this.state.searchQuery}
        onPaginationChange={this.onPaginationChange}
      />
    );
  }
}

AnsibleCollectionsPage.propTypes = {
  location: PropTypes.shape({
    search: PropTypes.oneOfType([
      PropTypes.shape({}),
      PropTypes.string,
    ]),
  }),
  getAnsibleCollections: PropTypes.func.isRequired,
  ansibleCollections: PropTypes.shape({}).isRequired,
};

AnsibleCollectionsPage.defaultProps = {
  location: { search: '' },
};


export default AnsibleCollectionsPage;
