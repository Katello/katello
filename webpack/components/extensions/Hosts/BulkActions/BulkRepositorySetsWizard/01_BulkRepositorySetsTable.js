import React, { useState, useContext } from 'react';
import PropTypes from 'prop-types';
import {
  Alert, Dropdown, DropdownItem, DropdownList,
  Divider, MenuToggle, MenuToggleAction, ToolbarItem,
} from '@patternfly/react-core';
import {
  Tr, Td, Tbody,
} from '@patternfly/react-table';
import { STATUS } from 'foremanReact/constants';
import { useForemanOrganization } from 'foremanReact/Root/Context/ForemanContext';
import { getPageStats, getColumnHelpers } from 'foremanReact/components/PF4/TableIndexPage/Table/helpers';
import { useSet } from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';
import { Table } from 'foremanReact/components/PF4/TableIndexPage/Table/Table';
import { translate as __ } from 'foremanReact/common/I18n';
import { RowSelectTd } from 'foremanReact/components/HostsIndex/RowSelectTd';
import SelectAllCheckbox from 'foremanReact/components/PF4/TableIndexPage/Table/SelectAllCheckbox';
import { noop } from 'foremanReact/common/helpers';

import katelloApi from '../../../../../services/api';
import { repoSetsUrlForOrg, BulkRepositorySetsWizardContext } from './BulkRepositorySetsWizard';

export const dropdownValues = {
  0: __('No change'),
  1: __('Override to enabled'),
  2: __('Override to disabled'),
  3: __('Reset to default'),
};

const ContentOverrideDropdown =
  ({
    repoLabel, pendingOverrides, setPendingOverrides, setShouldValidateStep1,
  }) => {
    const [isOpen, setIsOpen] = useState(false);

    const currentValue = pendingOverrides[repoLabel] ?? 0;
    const currentLabel = dropdownValues[currentValue];
    const onToggleClick = () => {
      setIsOpen(!isOpen);
    };
    const onSelect = (_event, value) => {
      setIsOpen(false);
      setShouldValidateStep1(true);
      setPendingOverrides({
        ...pendingOverrides,
        [repoLabel]: value,
      });
    };
    return (
      <Dropdown
        key={`pf-ContentOverrideDropdown-${repoLabel}`}
        isOpen={isOpen}
        onSelect={onSelect}
        onOpenChange={openVal => setIsOpen(!openVal)}
        toggle={toggleRef => (
          <MenuToggle ref={toggleRef} onClick={onToggleClick} isExpanded={isOpen}>
            {currentLabel}
          </MenuToggle>)}
        ouiaId={`ContentOverrideDropdown-${repoLabel}`}
        shouldFocusToggleOnSelect
      >
        <DropdownList>
          <DropdownItem value={0} key={`content-override-dropdown-${repoLabel}-no-change`} ouiaId={`content-override-dropdown-${repoLabel}-no-change`}>
            {__('No change')}
          </DropdownItem>
          <DropdownItem value={1} key={`content-override-dropdown-${repoLabel}-enable`} ouiaId={`content-override-dropdown-${repoLabel}-enable`}>
            {__('Override to enabled')}
          </DropdownItem>
          <DropdownItem value={2} key={`content-override-dropdown-${repoLabel}-disable`} ouiaId={`content-override-dropdown-${repoLabel}-disable`}>
            {__('Override to disabled')}
          </DropdownItem>
          <Divider key="divider" />
          <DropdownItem value={3} key={`content-override-dropdown-${repoLabel}-reset-to-default`} ouiaId={`content-override-dropdown-${repoLabel}-reset-to-default`}>
            {__('Reset to default')}
          </DropdownItem>
        </DropdownList>
      </Dropdown>
    );
  };

ContentOverrideDropdown.propTypes = {
  repoLabel: PropTypes.string.isRequired,
  pendingOverrides: PropTypes.shape({
    [PropTypes.string]: PropTypes.number,
  }).isRequired,
  setPendingOverrides: PropTypes.func.isRequired,
  setShouldValidateStep1: PropTypes.func.isRequired,
};

export const BulkRepositorySetsTable = ({
  repoSetsBulkSelect,
  repoSetsResults,
  repoSetsMetadata,
  repoSetsResponse,
}) => {
  const {
    selectPage,
    selectNone,
    selectOne,
    isSelected,
    selectedCount,
    selectedResults,
    areAllRowsSelected,
    areAllRowsOnPageSelected,
    updateSearchQuery,
  } = repoSetsBulkSelect;

  const repoSetsWizardContext = useContext(BulkRepositorySetsWizardContext);
  const {
    pendingOverrides, setPendingOverrides, shouldValidateStep1,
    setShouldValidateStep1, repoSetsSelectionIsValid,
    setRepoSetsParamsAndAPI,
  } = repoSetsWizardContext;
  const orgId = useForemanOrganization()?.id;
  const [actionDropdownValue, setActionDropdownValue] = useState(0);
  const [actionToggleOpen, setActionToggleOpen] = useState(false);

  const {
    total, page, subtotal, per_page: perPage,
  } = repoSetsMetadata;
  const apiOptions = { key: 'BULK_HOST_REPO_SETS' };
  const { status: repoSetsLoadingStatus } = repoSetsResponse;
  const pageStats = getPageStats({ total: subtotal, page, perPage });

  const expandedRepos = useSet([]);
  const repoIsExpanded = id => expandedRepos.has(id);

  const columns = {
    name: {
      title: __('Name'),
      wrapper: (repo) => {
        const productId = repo?.product?.id;
        const href = `/products/${productId}/repositories/`;
        return (
          <a target="_blank" href={href} rel="noreferrer">{repo.name}</a>
        );
      },
      isSorted: true,
      weight: 50,
    },
    enabled_by_default: {
      title: __('Status'),
      wrapper: ({ label }) => (
        <ContentOverrideDropdown
          key={label ?? 'no-label'}
          repoLabel={label}
          pendingOverrides={pendingOverrides}
          setPendingOverrides={setPendingOverrides}
          setShouldValidateStep1={setShouldValidateStep1}
        />
      ),
      isSorted: false,
      weight: 100,
    },
  };

  const selectionToolbar = (
    <ToolbarItem key="selectAll">
      <SelectAllCheckbox
        {...{
          selectAll: noop,
          selectOne,
          updateSearchQuery,
          selectNone,
          selectPage,
          selectedCount,
          pageRowCount: pageStats.pageRowCount,
          areAllRowsSelected,
          areAllRowsOnPageSelected,
        }}
        totalCount={total}
        areAllRowsOnPageSelected={areAllRowsOnPageSelected()}
        areAllRowsSelected={areAllRowsSelected()}
      />
    </ToolbarItem>
  );

  const onToggleClick = () => {
    setActionToggleOpen(!actionToggleOpen);
  };
  const handleActionToggle = (value) => {
    const result = {};
    selectedResults.forEach((repo) => {
      result[repo.label] = value;
    });
    setPendingOverrides({ ...pendingOverrides, ...result });
    setShouldValidateStep1(true);
  };
  const onSelect = (_event, value) => {
    handleActionToggle(value);
    setActionToggleOpen(false);
  };

  const actionButton = (
    <Dropdown
      isOpen={actionToggleOpen}
      onSelect={onSelect}
      onOpenChange={val => setActionToggleOpen(!val)}
      key="content-override-action-dropdown"
      ouiaId="content-override-action-dropdown"
      toggle={toggleRef => (
        <MenuToggle
          ref={toggleRef}
          onClick={onToggleClick}
          isExpanded={actionToggleOpen}
          variant="primary"
          splitButtonOptions={{
            variant: 'action',
            items: [
              <MenuToggleAction
                isDisabled={selectedCount === 0}
                id="split-button-action-example-with-toggle-button"
                key="split-action"
                aria-label="Action"
                onClick={() => handleActionToggle(actionDropdownValue)}
              >
                {dropdownValues[actionDropdownValue]}
              </MenuToggleAction>],
          }}
          aria-label="Content override action to apply to all selected repositories"
          isDisabled={selectedCount === 0}
        />
      )}
    >
      <DropdownList>
        {Object.entries(dropdownValues).map(([key, value]) => (
          <DropdownItem
            key={key}
            value={key}
            ouiaId={`content-override-action-dropdown-${key}`}
            onClick={() => setActionDropdownValue(key)}
          >
            {value}
          </DropdownItem>
        ))}
      </DropdownList>
    </Dropdown>
  );

  const [columnNamesKeys, keysToColumnNames] = getColumnHelpers(columns);

  return (
    <>
      {shouldValidateStep1 && !repoSetsSelectionIsValid && (
        <Alert
          ouiaId="no-reposet-changes-alert"
          variant="info"
          isInline
          title={__('Change the status of at least one repository.')}
          style={{ marginBottom: '1rem' }}
        />
      )}
      <TableIndexPage
        customToolbarItems={[actionButton]}
        selectionToolbar={selectionToolbar}
        results={repoSetsResults}
        metadata={repoSetsMetadata}
        response={repoSetsResponse}
        tableType="repository_sets"
        apiUrl={repoSetsUrlForOrg(orgId)}
        apiOptions={apiOptions}
        selectedCount={selectedCount}
        selectPage={selectPage}
        selectNone={selectNone}
        customSearchProps={{
          autocomplete: {
            url: katelloApi.getApiUrl('/repository_sets/auto_complete_search'),
          },
        }}
        bulkSelect={repoSetsBulkSelect}
        updateParamsByUrl={false}
      >
        <Table
          childrenOutsideTbody
          showCheckboxes
          rowSelectTd={RowSelectTd}
          selectOne={selectOne}
          isSelected={isSelected}
          isEmbedded
          idColumn="label"
          columns={columns}
          refreshData={noop}
          url=""
          results={repoSetsResults}
          isPending={repoSetsLoadingStatus === STATUS.PENDING}
          params={{ ...repoSetsMetadata, perPage, page }}
          setParams={setRepoSetsParamsAndAPI}
          page={page}
          perPage={perPage}
          itemCount={subtotal}
        >
          {repoSetsResults.map((result, rowIndex) => {
            const repoLabel = result.label;
            const isExpanded = repoIsExpanded(repoLabel);
            return (
              <Tbody isExpanded={isExpanded} key={`tbody1-${repoLabel}`}>
                <Tr
                  key={repoLabel}
                  ouiaId={`table-row-${rowIndex}`}
                  isClickable
                >
                  <Td
                    expand={{
                      rowIndex,
                      isExpanded,
                      onToggle: (_event, _rInx, isOpen) =>
                        expandedRepos.onToggle(isOpen, repoLabel),
                    }}
                  />
                  <RowSelectTd
                    rowData={result}
                    selectOne={selectOne}
                    isSelected={isSelected}
                    idColumnName="label"
                  />
                  {columnNamesKeys.map(k => (
                    <Td key={k} dataLabel={keysToColumnNames[k]}>
                      {columns[k].wrapper
                        ? columns[k].wrapper(result)
                        : result[k]}
                    </Td>
                  ))}
                </Tr>
                <Tr key={`child-row-${repoLabel}`} ouiaId={`child-row-${repoLabel}`} isExpanded={isExpanded}>
                  <Td />
                  <Td />
                  <Td colSpan={2}>
                    <pre style={{ marginTop: '0.63rem' }} id={`pre-repo-label-${repoLabel}`}>{repoLabel}</pre>
                  </Td>
                </Tr>
              </Tbody>
            );
          })}
        </Table>
      </TableIndexPage>
    </>
  );
};

BulkRepositorySetsTable.propTypes = {
  repoSetsBulkSelect: PropTypes.shape({
    selectAll: PropTypes.func.isRequired,
    selectPage: PropTypes.func.isRequired,
    selectNone: PropTypes.func.isRequired,
    selectOne: PropTypes.func.isRequired,
    isSelected: PropTypes.func.isRequired,
    selectedCount: PropTypes.number.isRequired,
    areAllRowsSelected: PropTypes.func.isRequired,
    areAllRowsOnPageSelected: PropTypes.func.isRequired,
    updateSearchQuery: PropTypes.func.isRequired,
    selectedResults: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  }).isRequired,
  repoSetsResults: PropTypes.arrayOf(PropTypes.shape({})),
  repoSetsMetadata: PropTypes.shape({
    total: PropTypes.number,
    page: PropTypes.number,
    subtotal: PropTypes.number,
    per_page: PropTypes.number,
  }).isRequired,
  repoSetsResponse: PropTypes.shape({
    response: PropTypes.shape({}),
    status: PropTypes.string,
  }).isRequired,
};

BulkRepositorySetsTable.defaultProps = {
  repoSetsResults: [],
};

export default BulkRepositorySetsTable;
