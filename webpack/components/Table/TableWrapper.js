import React, { useCallback, useRef } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import PropTypes from 'prop-types';
import { useDispatch } from 'react-redux';
import { dequal as deepEqual } from 'dequal';
import { STATUS } from 'foremanReact/constants';
import { noop } from 'foremanReact/common/helpers';
import { useForemanSettings } from 'foremanReact/Root/Context/ForemanContext';
import { PaginationVariant, Flex, FlexItem } from '@patternfly/react-core';

import PageControls from './PageControls';
import MainTable from './MainTable';
import { getPageStats } from './helpers';
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
  ...allTableProps
}) => {
  const dispatch = useDispatch();
  const foremanPerPage = useForemanSettings().perPage || 20;
  const perPage = Number(metadata?.per_page ?? foremanPerPage);
  const page = Number(metadata?.page ?? 1);
  const total = Number(metadata?.subtotal ?? 0);
  const { pageRowCount } = getPageStats({ total, page, perPage });
  const totalCount = metadata?.total ?? 0;
  const unresolvedStatus = !!allTableProps?.status && allTableProps.status !== STATUS.RESOLVED;
  const unresolvedStatusOrNoRows = unresolvedStatus || pageRowCount === 0;
  const searchNotUnderway = !(searchQuery || activeFilters);
  const paginationParams = useCallback(() =>
    ({ per_page: perPage, page }), [perPage, page]);
  const prevRequest = useRef({});
  const prevSearch = useRef('');
  const prevAdditionalListeners = useRef([]);
  const paginationChangePending = useRef(null);

  const hasChanged = (oldValue, newValue) => !deepEqual(oldValue, newValue);

  const spawnFetch = useCallback((paginationData) => {
    // The search component will update the search query when a search is performed, listen for that
    // and perform the search so we can be sure the searchQuery is updated when search is performed.
    const fetchWithParams = (allParams = {}) => {
      const newRequest = {
        ...(paginationData ?? paginationParams()),
        ...allParams,
      };
      // If a pagination change is in-flight,
      // don't send another request with stale data
      if (paginationChangePending.current &&
        hasChanged(newRequest, paginationChangePending.current)) return;
      paginationChangePending.current = null;
      if (hasChanged(newRequest, prevRequest.current) ||
          hasChanged(additionalListeners, prevAdditionalListeners.current)
      ) {
        // don't fire the same request twice in a row
        prevRequest.current = newRequest;
        prevAdditionalListeners.current = additionalListeners;
        dispatch(fetchItems(newRequest));
      }
    };
    let pageOverride;
    if (searchQuery) pageOverride = { search: searchQuery };
    if (!deepEqual(searchQuery, prevSearch.current) || activeFilters) {
      // Reset page back to 1 when filter or search changes
      prevSearch.current = searchQuery;
      pageOverride = { search: searchQuery, page: 1 };
    }
    fetchWithParams(pageOverride);
  }, [
    activeFilters,
    dispatch,
    fetchItems,
    paginationParams,
    searchQuery,
    additionalListeners,
    // prevAdditionalListeners,
  ]);

  useDeepCompareEffect(() => {
    spawnFetch();
  }, [searchQuery, spawnFetch, additionalListeners]);

  const getAutoCompleteParams = search => ({
    endpoint: autocompleteEndpoint,
    params: {
      organization_id: orgId(),
      search,
    },
  });

  // If the new page wouldn't exist because of a perPage change,
  // we should set the current page to the last page.
  const validatePagination = (data) => {
    const mergedData = { ...paginationParams(), ...data };
    const { page: requestedPage, per_page: newPerPage } = mergedData;
    const { lastPage } = getPageStats({
      page: requestedPage,
      perPage: newPerPage,
      total,
    });
    const result = {};
    if (requestedPage) {
      const newPage = (requestedPage > lastPage) ? lastPage : requestedPage;
      result.page = Number(newPage);
    }
    if (newPerPage) result.per_page = Number(newPerPage);
    return result;
  };

  const onPaginationUpdate = (updatedPagination) => {
    const pagData = validatePagination(updatedPagination);
    spawnFetch(pagData);
    paginationChangePending.current = pagData;
  };

  return (
    <>
      <Flex>
        {displaySelectAllCheckbox &&
          <FlexItem alignSelf={{ default: 'alignSelfCenter' }}>
            <SelectAllCheckbox
              selectAll={selectAll}
              selectNone={selectNone}
              selectPage={selectPage}
              selectedCount={selectedCount}
              pageRowCount={pageRowCount}
              totalCount={totalCount}
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
        <PageControls
          variant={PaginationVariant.top}
          total={total}
          page={page}
          perPage={perPage}
          onPaginationUpdate={onPaginationUpdate}
        />
      </Flex>
      <MainTable
        searchIsActive={!!searchQuery}
        activeFilters={activeFilters}
        rowsCount={pageRowCount}
        {...allTableProps}
      >
        {children}
      </MainTable>
      <Flex>
        <PageControls
          variant={PaginationVariant.bottom}
          total={total}
          page={page}
          perPage={perPage}
          onPaginationUpdate={onPaginationUpdate}
        />
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
  selectAll: noop,
  selectNone: noop,
  selectPage: noop,
  areAllRowsSelected: noop,
  areAllRowsOnPageSelected: noop,
};

export default TableWrapper;
