import React, { useState, useCallback } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { Pagination, Flex, FlexItem } from '@patternfly/react-core';

import PropTypes from 'prop-types';
import { useDispatch } from 'react-redux';
import { STATUS } from 'foremanReact/constants';
import { useForemanSettings } from 'foremanReact/Root/Context/ForemanContext';
import { usePaginationOptions } from 'foremanReact/components/Pagination/PaginationHooks';

import MainTable from './MainTable';
import Search from '../../components/Search';
import { orgId } from '../../services/api';

/* Patternfly 4 table wrapper */
const TableWrapper = ({
  children,
  metadata,
  fetchItems,
  autocompleteEndpoint,
  searchQuery,
  updateSearchQuery,
  additionalListeners,
  activeFilters,
  composable,
  ...allTableProps
}) => {
  const dispatch = useDispatch();
  const foremanPerPage = useForemanSettings().perPage || 20;
  // setting pagination to local state so it doesn't disappear when page reloads
  const [perPage, setPerPage] = useState(Number(metadata?.per_page ?? foremanPerPage));
  const [page, setPage] = useState(Number(metadata?.page ?? 1));
  const [total, setTotal] = useState(Number(metadata?.subtotal ?? 0));


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
    composable,
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

  const rowsCount = metadata?.subtotal ?? 0;
  const unresolvedStatus = !!allTableProps?.status && allTableProps.status !== STATUS.RESOLVED;
  const unresolvedStatusOrNoRows = unresolvedStatus || rowsCount === 0;
  const searchNotUnderway = !(searchQuery || activeFilters);

  return (
    <>
      <Flex>
        <FlexItem>
          <Search
            isDisabled={unresolvedStatusOrNoRows && searchNotUnderway}
            patternfly4
            onSearch={search => updateSearchQuery(search)}
            getAutoCompleteParams={getAutoCompleteParams}
          />
        </FlexItem>
        {!composable &&
          <FlexItem>
            {children}
          </FlexItem>
        }
        <FlexItem align={{ default: 'alignRight' }}>
          <Pagination
            itemCount={total}
            page={page}
            perPage={perPage}
            onSetPage={(_evt, updated) => onPaginationUpdate({ page: updated })}
            onPerPageSelect={(_evt, updated) => onPaginationUpdate({ per_page: updated })}
            perPageOptions={usePaginationOptions().map(p => ({ title: p.toString(), value: p }))}
            variant="top"
          />
        </FlexItem>
      </Flex>
      <MainTable
        searchIsActive={!!searchQuery}
        activeFilters={activeFilters}
        composable={composable}
        rowsCount={rowsCount}
        {...allTableProps}
      >
        {children}
      </MainTable>
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
  children: PropTypes.node,
  // additionalListeners are anything that can trigger another API call, e.g. a filter
  additionalListeners: PropTypes.arrayOf(PropTypes.oneOfType([
    PropTypes.number,
    PropTypes.string,
    PropTypes.bool,
  ])),
  activeFilters: PropTypes.bool,
  composable: PropTypes.bool,
};

TableWrapper.defaultProps = {
  metadata: { subtotal: 0 },
  children: null,
  additionalListeners: [],
  activeFilters: false,
  composable: false,
};

export default TableWrapper;
