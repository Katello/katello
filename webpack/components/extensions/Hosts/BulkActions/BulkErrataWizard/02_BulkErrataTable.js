import React, { useEffect, useContext } from 'react';
import {
  Alert,
  ToolbarItem,
  Text,
  TextContent,
  TextVariants,
} from '@patternfly/react-core';
import { TableText } from '@patternfly/react-table';
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';
import { translate as __ } from 'foremanReact/common/I18n';
import SelectAllCheckbox from 'foremanReact/components/PF4/TableIndexPage/Table/SelectAllCheckbox';
import { STATUS, getControllerSearchProps } from 'foremanReact/constants';
import { RowSelectTd } from 'foremanReact/components/HostsIndex/RowSelectTd';
import { getPageStats } from 'foremanReact/components/PF4/TableIndexPage/Table/helpers';
import { BulkErrataWizardContext, ERRATA_URL } from './BulkErrataWizard';
import { ErrataType, ErrataSeverity } from '../../../../../components/Errata';
import katelloApi from '../../../../../services/api';

const BulkErrataTable = () => {
  const {
    setShouldValidateStep2,
    errataBulkSelect,
    errataResults: results,
    errataMetadata: {
      total, per_page: perPage, page, subtotal,
    },
    errataResponse: response,
  } = useContext(BulkErrataWizardContext);
  const apiOptions = { key: 'BULK_HOST_ERRATA' };
  const {
    status: errataStatus,
  } = response;


  const origSearchProps = getControllerSearchProps('errata', 'searchBar-errata');
  const customSearchProps = {
    ...origSearchProps,
    autocomplete: {
      ...origSearchProps.autocomplete,
      url: katelloApi.getApiUrl('/errata/auto_complete_search'),
    },
  };

  const {
    selectAll,
    selectPage,
    selectNone,
    selectOne,
    isSelected,
    selectedCount,
    areAllRowsSelected,
    areAllRowsOnPageSelected,
    updateSearchQuery,
    hasInteracted,
  } = errataBulkSelect;

  useEffect(() => {
    if (results?.length && hasInteracted) {
      setShouldValidateStep2(true);
    }
  }, [setShouldValidateStep2, results, hasInteracted]);

  const pageStats = getPageStats({ total: subtotal, page, perPage });
  const selectionToolbar = (
    <ToolbarItem key="selectAll">
      <SelectAllCheckbox
        {...{
          selectNone,
          selectPage,
          selectedCount,
          pageRowCount: pageStats.pageRowCount,
          areAllRowsSelected,
          areAllRowsOnPageSelected,
        }}
        selectAll={selectAll}
        totalCount={total}
        areAllRowsOnPageSelected={areAllRowsOnPageSelected()}
        areAllRowsSelected={areAllRowsSelected()}
      />
    </ToolbarItem>
  );

  const columns = {
    id: {
      title: __('Erratum'),
      wrapper: ({ id, errata_id: errataId }) => (
        <a target="_blank" href={`/errata/${id}`} rel="noreferrer">{errataId}</a>
      ),
      isSorted: true,
      weight: 10,
    },
    title: {
      title: __('Title'),
      wrapper: ({ title }) => <TableText wrapModifier="truncate">{title}</TableText>,
      isSorted: true,
      weight: 20,
    },
    type: {
      title: __('Type'),
      wrapper: erratum => <ErrataType {...erratum} />,
      weight: 30,
      isSorted: true,
    },
    severity: {
      title: __('Severity'),
      wrapper: erratum => <ErrataSeverity {...erratum} />,
      weight: 40,
      isSorted: true,
    },
    affectedHosts: {
      title: __('Affected hosts'),
      wrapper: ({ affected_hosts_count: affectedHostsCount }) => affectedHostsCount,
      weight: 50,
    },
  };

  return (
    <>
      <TextContent>
        <Text ouiaId="mew-step-3-header" component={TextVariants.h3}>
          {__('Apply errata')}
        </Text>
        <Text ouiaId="mew-step-3-content" component={TextVariants.p}>
          {__('Select errata to apply on the selected hosts. Some errata may already be applied on some hosts.')}
        </Text>
      </TextContent>
      {selectedCount === 0 && hasInteracted && (
        <Alert
          ouiaId="no-errata-alert"
          variant="info"
          isInline
          title={__('Select at least one erratum.')}
          style={{ marginBottom: '1rem' }}
        />
      )}
      { errataStatus === STATUS.RESOLVED && !results?.length && (
        <Alert
          ouiaId="no-errata-found-alert"
          variant="info"
          isInline
          title={__('No errata found.')}
          style={{ marginBottom: '1rem' }}
        />
      )}
      <TableIndexPage
        columns={columns}
        showCheckboxes
        apiUrl={ERRATA_URL}
        apiOptions={apiOptions}
        headerText={__('Errata')}
        header={null}
        controller="errata"
        customSearchProps={customSearchProps}
        creatable={false}
        replacementResponse={response}
        selectionToolbar={selectionToolbar}
        updateSearchQuery={updateSearchQuery}
        rowSelectTd={RowSelectTd}
        selectOne={selectOne}
        isSelected={isSelected}
        idColumn="errata_id"
        updateParamsByUrl={false}
        bookmarksPosition="right"
      />
    </>
  );
};


export default BulkErrataTable;
