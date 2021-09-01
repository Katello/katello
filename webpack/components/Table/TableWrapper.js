import React, { useState, useCallback } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { Pagination, PaginationVariant, Flex, FlexItem } from '@patternfly/react-core';

import PropTypes from 'prop-types';
import { useDispatch } from 'react-redux';
import { STATUS } from 'foremanReact/constants';
import { noop } from 'foremanReact/common/helpers';
import { useForemanSettings } from 'foremanReact/Root/Context/ForemanContext';
import { usePaginationOptions } from 'foremanReact/components/Pagination/PaginationHooks';

import MainTable from './MainTable';
import Search from '../../components/Search';
import SelectAllCheckbox from '../SelectAllCheckbox';
import { orgId } from '../../services/api';

/* Patternfly 4 table wrapper */
const TableWrapper = ({
  actionButtons,
  children,
  metadata,
  fetchItems,
  autocompleteEndpoint,
  foremanApiAutoComplete,
  searchQuery,
  updateSearchQuery,
  additionalListeners,
  activeFilters,
  displaySelectAllCheckbox,
  selectAll,
  selectNone,
  selectPage,
  areAllRowsSelected,
  areAllRowsOnPageSelected,
  selectedCount,
  modelName,
  modelNamePlural,
  ...allTableProps
}) => {
  const dispatch = useDispatch();
  const foremanPerPage = useForemanSettings().perPage || 20;
  // setting pagination to local state so it doesn't disappear when page reloads
  const [perPage, setPerPage] = useState(Number(metadata?.per_page ?? foremanPerPage));
  const [page, setPage] = useState(Number(metadata?.page ?? 1));
  const [total, setTotal] = useState(Number(metadata?.subtotal ?? 0));

  const rowsCount = metadata?.subtotal ?? 0;
  const unresolvedStatus = !!allTableProps?.status && allTableProps.status !== STATUS.RESOLVED;
  const unresolvedStatusOrNoRows = unresolvedStatus || rowsCount === 0;
  const searchNotUnderway = !(searchQuery || activeFilters);

  const updatePagination = (data) => {
    const { subtotal: newTotal, page: newPage, per_page: newPerPage } = data;
    if (newTotal !== undefined) setTotal(Number(newTotal));
    if (newPage !== undefined) setPage(Number(newPage));
    if (newPerPage !== undefined) setPerPage(Number(newPerPage));
  };
  const paginationParams = useCallback(() => ({ per_page: perPage, page }), [perPage, page]);

  useDeepCompareEffect(() => updatePagination(metadata), [metadata]);

  // The search component will update the search query when a search is performed, listen for that
  // and perform the search so we can be sure the searchQuery is updated when search is performed.
  useDeepCompareEffect(() => {
    const fetchWithParams = (allParams = {}) => {
      dispatch(fetchItems({ ...paginationParams(), ...allParams }));
    };
    if (searchQuery || activeFilters) {
      // Reset page back to 1 when filter or search changes
      fetchWithParams({ search: searchQuery, page: 1 });
    } else {
      fetchWithParams();
    }
  }, [
    activeFilters,
    dispatch,
    fetchItems,
    paginationParams,
    searchQuery,
    additionalListeners,
  ]);

  const getAutoCompleteParams = search => ({
    endpoint: autocompleteEndpoint,
    params: {
      organization_id: orgId(),
      search,
    },
  });
  const onPaginationUpdate = (updatedPagination) => {
    updatePagination(updatedPagination);
  };

  const PageControls = ({ variant }) => (
    <FlexItem align={{ default: 'alignRight' }}>
      <Pagination
        key={variant}
        itemCount={total}
        page={page}
        perPage={perPage}
        isCompact={variant === PaginationVariant.top}
        onSetPage={(_evt, updated) => onPaginationUpdate({ page: updated })}
        onPerPageSelect={(_evt, updated) => onPaginationUpdate({ per_page: updated })}
        perPageOptions={usePaginationOptions().map(p => ({ title: p.toString(), value: p }))}
        variant={variant}
      />
    </FlexItem>
  );

  PageControls.propTypes = {
    variant: PropTypes.string.isRequired,
  };

  return (
    <>
      <Flex>
        {displaySelectAllCheckbox &&
          <FlexItem>
            <SelectAllCheckbox
              selectAll={selectAll}
              selectNone={selectNone}
              selectPage={selectPage}
              selectedCount={selectedCount}
              modelName={modelName}
              modelNamePlural={modelNamePlural}
              rowsCount={rowsCount}
              areAllRowsSelected={areAllRowsSelected()}
              areAllRowsOnPageSelected={areAllRowsOnPageSelected()}
            />
          </FlexItem>
        }
        <FlexItem>
          <Search
            isDisabled={unresolvedStatusOrNoRows && searchNotUnderway}
            patternfly4
            onSearch={search => updateSearchQuery(search)}
            getAutoCompleteParams={getAutoCompleteParams}
            foremanApiAutoComplete={foremanApiAutoComplete}
          />
        </FlexItem>
        <FlexItem>
          {actionButtons}
        </FlexItem>
        <PageControls variant={PaginationVariant.top} />
      </Flex>
      <MainTable
        searchIsActive={!!searchQuery}
        activeFilters={activeFilters}
        rowsCount={rowsCount}
        {...allTableProps}
      >
        {children}
      </MainTable>
      <Flex>
        <PageControls variant={PaginationVariant.bottom} />
      </Flex>
    </>
  );
};

TableWrapper.propTypes = {
  searchQuery: PropTypes.string.isRequired,
  updateSearchQuery: PropTypes.func.isRequired,
  fetchItems: PropTypes.func.isRequired,
  metadata: PropTypes.shape({
    total: PropTypes.number,
    page: PropTypes.oneOfType([
      PropTypes.number,
      PropTypes.string, // The API can sometimes return strings
    ]),
    subtotal: PropTypes.oneOfType([
      PropTypes.number,
      PropTypes.string, // The API can sometimes return strings
    ]),
    per_page: PropTypes.oneOfType([
      PropTypes.number,
      PropTypes.string,
    ]),
    search: PropTypes.string,
  }),
  autocompleteEndpoint: PropTypes.string.isRequired,
  foremanApiAutoComplete: PropTypes.bool,
  actionButtons: PropTypes.node,
  children: PropTypes.node,
  // additionalListeners are anything that can trigger another API call, e.g. a filter
  additionalListeners: PropTypes.arrayOf(PropTypes.oneOfType([
    PropTypes.number,
    PropTypes.string,
    PropTypes.bool,
  ])),
  activeFilters: PropTypes.bool,
  displaySelectAllCheckbox: PropTypes.bool,
  selectedCount: PropTypes.number,
  modelName: PropTypes.string,
  modelNamePlural: PropTypes.string,
  selectAll: PropTypes.func,
  selectNone: PropTypes.func,
  selectPage: PropTypes.func,
  areAllRowsSelected: PropTypes.func,
  areAllRowsOnPageSelected: PropTypes.func,
};

TableWrapper.defaultProps = {
  metadata: { subtotal: 0 },
  children: null,
  additionalListeners: [],
  activeFilters: false,
  foremanApiAutoComplete: false,
  actionButtons: null,
  displaySelectAllCheckbox: false,
  selectedCount: 0,
  modelName: 'item',
  modelNamePlural: undefined,
  selectAll: noop,
  selectNone: noop,
  selectPage: noop,
  areAllRowsSelected: noop,
  areAllRowsOnPageSelected: noop,
};

export default TableWrapper;
