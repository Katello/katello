import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { useUrlParams } from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import { translate as __ } from 'foremanReact/common/I18n';
import { orgId } from '../../services/api';
import TableSchema from '../ModuleStreams/ModuleStreamsTableSchema';
import GenericContentPage from '../../components/Content/GenericContentPage';

const ModuleStreamsPage = (props) => {
  const { searchParam } = useUrlParams();
  const [searchQuery, setSearchQuery] = useState(searchParam || '');
  const { getModuleStreams } = props;

  useEffect(() => {
    getModuleStreams({
      search: searchQuery,
    });
  }, [getModuleStreams, searchQuery]);

  const onPaginationChange = (pagination) => {
    props.getModuleStreams({
      ...pagination,
    });
  };

  const onSearch = (search) => {
    props.getModuleStreams({ search });
  };

  const updateSearchQuery = (newSearchQuery) => {
    setSearchQuery(newSearchQuery);
  };

  const { moduleStreams } = props;
  return (
    <GenericContentPage
      header={__('Module Streams')}
      content={moduleStreams}
      tableSchema={TableSchema}
      onSearch={onSearch}
      autocompleteEndpoint="/katello/api/v2/module_streams"
      autocompleteQueryParams={{ organization_id: orgId() }}
      bookmarkController="katello_module_streams"
      updateSearchQuery={updateSearchQuery}
      initialInputValue={searchQuery}
      onPaginationChange={onPaginationChange}
    />
  );
};


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
