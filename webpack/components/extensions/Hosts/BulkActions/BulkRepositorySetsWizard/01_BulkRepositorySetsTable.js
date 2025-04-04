import React, { useState, useContext } from 'react';
import PropTypes from 'prop-types';
import { Dropdown, DropdownItem, DropdownList, Divider, MenuToggle, ToolbarItem } from '@patternfly/react-core';
import { getPageStats } from 'foremanReact/components/PF4/TableIndexPage/Table/helpers';
import TableIndexPage from 'foremanReact/components/PF4/TableIndexPage/TableIndexPage';
import { translate as __ } from 'foremanReact/common/I18n';
import { RowSelectTd } from 'foremanReact/components/HostsIndex/RowSelectTd';
import SelectAllCheckbox from 'foremanReact/components/PF4/TableIndexPage/Table/SelectAllCheckbox';

import katelloApi from '../../../../../services/api';
import { REPO_SETS_URL, BulkRepositorySetsWizardContext } from './BulkRepositorySetsWizard';

const ContentOverrideDropdown = ({ repoLabel, pendingOverrides, setPendingOverrides }) => {
  const [isOpen, setIsOpen] = useState(false);
  const dropdownValues = {
    0: __('No change'),
    1: __('Override to enabled'),
    2: __('Override to disabled'),
    3: __('Reset to default'),
  };

  const currentValue = pendingOverrides[repoLabel] ?? 0;
  const currentLabel = dropdownValues[currentValue];
  const onToggleClick = () => {
    setIsOpen(!isOpen);
  };
  const onSelect = (_event, value) => {
    setIsOpen(false);
    if (value === 0) {
      // remove the override from pending; user does not want to change it
      const { [repoLabel]: _, ...rest } = pendingOverrides;
      setPendingOverrides(rest);
    } else {
      setPendingOverrides({
        ...pendingOverrides,
        [repoLabel]: value,
      });
    }
  };
  return (
    <Dropdown
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
        <DropdownItem value={0} key="no-change" ouiaId={`content-override-dropdown-${repoLabel}-no-change`}>
          {__('No change')}
        </DropdownItem>
        <DropdownItem value={1} key="enable" ouiaId={`content-override-dropdown-${repoLabel}-enable`}>
          {__('Override to enabled')}
        </DropdownItem>
        <DropdownItem value={2} key="disable" ouiaId={`content-override-dropdown-${repoLabel}-disable`}>
          {__('Override to disabled')}
        </DropdownItem>
        <Divider key="divider" />
        <DropdownItem value={3} key="reset-to-default" ouiaId={`content-override-dropdown-${repoLabel}-reset-to-default`}>
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
};

export const BulkRepositorySetsTable = ({
  repoSetsBulkSelect,
  repoSetsResults,
  repoSetsMetadata,
  repoSetsResponse,
}) => {
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
    setSelectedCount,
  } = repoSetsBulkSelect;

  const repoSetsWizardContext = useContext(BulkRepositorySetsWizardContext);
  const { pendingOverrides, setPendingOverrides } = repoSetsWizardContext;

  const {
    total, page, subtotal, per_page: perPage,
  } = repoSetsMetadata;

  const pageStats = getPageStats({ total: subtotal, page, perPage });

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
      wrapper: ({ content }) => (
        <ContentOverrideDropdown
          key={content?.label ?? 'no-label'}
          repoLabel={content?.label}
          pendingOverrides={pendingOverrides}
          setPendingOverrides={setPendingOverrides}
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
          selectAll,
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

  return (
    <TableIndexPage
      showCheckboxes
      updateParamsByUrl={false}
      rowSelectTd={RowSelectTd}
      selectionToolbar={selectionToolbar}
      columns={columns}
      results={repoSetsResults}
      metadata={repoSetsMetadata}
      response={repoSetsResponse}
      tableType="repository_sets"
      apiUrl={REPO_SETS_URL}
      apiOptions={{ key: 'BULK_HOST_REPO_SETS' }}
      selectOne={selectOne}
      isSelected={isSelected}
      setSelectedCount={setSelectedCount}
      selectedCount={selectedCount}
      selectPage={selectPage}
      selectNone={selectNone}
      customSearchProps={{
        autocomplete: {
          url: katelloApi.getApiUrl('/repository_sets/auto_complete_search'),
        },
      }}
      bulkSelect={repoSetsBulkSelect}
    />
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
    setSelectedCount: PropTypes.func.isRequired,
  }).isRequired,
  repoSetsResults: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
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

export default BulkRepositorySetsTable;
