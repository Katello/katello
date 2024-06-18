import React, { useEffect } from 'react'; // Don't useContext here so this component is reusable
import PropTypes from 'prop-types';
import {
  Alert,
  ToolbarItem,
  Text,
  TextContent,
  TextVariants,
} from '@patternfly/react-core';
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';
import { HOSTS_API_PATH } from 'foremanReact/routes/Hosts/constants';
import { translate as __ } from 'foremanReact/common/I18n';
import SelectAllCheckbox from 'foremanReact/components/PF4/TableIndexPage/Table/SelectAllCheckbox';
import { RowSelectTd } from 'foremanReact/components/HostsIndex/RowSelectTd';
import { getPageStats } from 'foremanReact/components/PF4/TableIndexPage/Table/helpers';

const HostReview = ({
  initialSelectedHosts,
  hostsBulkSelect,
  setShouldValidateStep,
}) => {
  const apiOptions = { key: 'HOST_REVIEW' };

  const {
    hostsBulkSelect: {
      selectPage,
      selectAll,
      selectNone,
      selectOne,
      isSelected,
      selectedCount,
      areAllRowsSelected,
      areAllRowsOnPageSelected,
      updateSearchQuery,
      hasInteracted,
    },
    hostsMetadata: {
      subtotal,
      total,
      page,
      per_page: perPage,
    },
    hostsResponse: response,
  } = hostsBulkSelect;

  const { response: { results } = {} } = response;

  useEffect(() => {
    if (results?.length && hasInteracted) {
      setShouldValidateStep(true);
    }
  }, [setShouldValidateStep, results?.length, hasInteracted]);

  const pageStats = getPageStats({ total: subtotal, page, perPage });
  const selectionToolbar = (
    <ToolbarItem key="selectAll">
      <SelectAllCheckbox
        {...{
          selectedCount,
          pageRowCount: pageStats.pageRowCount,
          areAllRowsSelected,
          areAllRowsOnPageSelected,
          selectAll,
          selectNone,
          selectPage,
        }}
        totalCount={total}
        areAllRowsOnPageSelected={areAllRowsOnPageSelected()}
        areAllRowsSelected={areAllRowsSelected()}
      />
    </ToolbarItem>
  );

  const columns = {
    name: {
      title: __('Name'),
      wrapper: ({ name, display_name: displayName }) => (
        <a target="_blank" href={`hosts/${name}`} rel="noreferrer">{displayName}</a>
      ),
      isSorted: true,
      weight: 50,
    },
    os_title: {
      title: __('OS'),
      wrapper: hostDetails => hostDetails?.operatingsystem_name,
      isSorted: true,
      weight: 100,
    },
  };

  // restrict search query to only selected hosts
  const restrictedSearchQuery = (newSearch) => {
    let newSearchQuery = initialSelectedHosts;
    const trimmedSearch = newSearch?.trim() ?? '';
    if (!!trimmedSearch && !trimmedSearch.includes(initialSelectedHosts)) {
      newSearchQuery = `${initialSelectedHosts} and ${trimmedSearch}`;
    }
    return newSearchQuery;
  };

  return (
    <>
      <TextContent>
        <Text ouiaId="mpw-step-3-header" component={TextVariants.h3}>
          {__('Review hosts')}
        </Text>
        <Text ouiaId="mpw-step-3-content" component={TextVariants.p}>
          {__('Review and optionally exclude hosts from your selection.')}
        </Text>
      </TextContent>
      {selectedCount === 0 && hasInteracted && (
        <Alert
          ouiaId="no-hosts-alert"
          variant="danger"
          isInline
          title={__('You must select at least one host.')}
          style={{ marginBottom: '1rem' }}
        />
      )}
      <TableIndexPage
        columns={columns}
        showCheckboxes
        apiUrl={HOSTS_API_PATH}
        apiOptions={apiOptions}
        headerText={__('Hosts')}
        header={null}
        controller="hosts"
        creatable={false}
        replacementResponse={response}
        selectionToolbar={selectionToolbar}
        updateSearchQuery={updateSearchQuery}
        restrictedSearchQuery={restrictedSearchQuery}
        rowSelectTd={RowSelectTd}
        selectOne={selectOne}
        isSelected={isSelected}
        updateParamsByUrl={false}
        bookmarksPosition="right"
      />
    </>
  );
};

HostReview.propTypes = {
  initialSelectedHosts: PropTypes.string,
  hostsBulkSelect: PropTypes.shape({
    hostsBulkSelect: PropTypes.shape({
      selectPage: PropTypes.func,
      selectAll: PropTypes.func,
      selectNone: PropTypes.func,
      selectOne: PropTypes.func,
      exclusionSet: PropTypes.object, // eslint-disable-line react/forbid-prop-types
      isSelected: PropTypes.func,
      selectedCount: PropTypes.number,
      areAllRowsSelected: PropTypes.func,
      areAllRowsOnPageSelected: PropTypes.func,
      updateSearchQuery: PropTypes.func,
      inclusionSet: PropTypes.object, // eslint-disable-line react/forbid-prop-types
      hasInteracted: PropTypes.bool,
    }),
    hostsMetadata: PropTypes.shape({
      total: PropTypes.number,
      page: PropTypes.number,
      per_page: PropTypes.number,
      subtotal: PropTypes.number,
    }),
    hostsResponse: PropTypes.shape([]),
  }),
  setShouldValidateStep: PropTypes.func.isRequired,
};

HostReview.defaultProps = {
  hostsBulkSelect: {},
  initialSelectedHosts: '',
};

export default HostReview;
