import React, { useCallback, useRef } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import PropTypes from 'prop-types';
import { useDispatch } from 'react-redux';
import { isEqual } from 'lodash';
import { STATUS } from 'foremanReact/constants';
import { noop } from 'foremanReact/common/helpers';
import { useForemanSettings } from 'foremanReact/Root/Context/ForemanContext';
import { PaginationVariant, Flex, FlexItem } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
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
  areAllRowsOnPageSelected,
  areAllRowsSelected,
  selectedCount,
  emptySearchBody,
  disableSearch,
  nodesBelowSearch,
  ...allTableProps
}) => {
  const dispatch = useDispatch();
  const foremanPerPage = useForemanSettings().perPage || 20;
  const perPage = Number(metadata?.per_page ?? foremanPerPage);
  const page = Number(metadata?.page ?? 1);
  const total = Number(metadata?.subtotal ?? 0);
  const { pageRowCount } = getPageStats({ total, page, perPage });
  const unresolvedStatus = !!allTableProps?.status && allTableProps.status !== STATUS.RESOLVED;
  const unresolvedStatusOrNoRows = unresolvedStatus || pageRowCount === 0;
  const searchNotUnderway = !(searchQuery || activeFilters);
  const showPagination = !unresolvedStatusOrNoRows;
  const showActionButtons = actionButtons && !unresolvedStatus;
  const paginationParams = useCallback(() =>
    ({ per_page: perPage, page }), [perPage, page]);
  const prevRequest = useRef({});
  const prevSearch = useRef('');
  const prevAdditionalListeners = useRef([]);
  const prevActiveFilters = useRef([]);
  const paginationChangePending = useRef(null);

  const hasChanged = (oldValue, newValue) => !isEqual(oldValue, newValue);

  const spawnFetch = useCallback((paginationData) => {
    console.log('--------')
    console.log('spawnFetch')
    // The search component will update the search query when a search is performed, listen for that
    // and perform the search so we can be sure the searchQuery is updated when search is performed.
    const fetchWithParams = (allParams = {}) => {
      // console.log('fetchWithParams')
      const newRequest = {
        ...(paginationData ?? paginationParams()),
        ...allParams,
      };
      const newRequestHasStalePagination = !!(paginationChangePending.current &&
        hasChanged(newRequest, paginationChangePending.current));
      const newRequestHasChanged = hasChanged(newRequest, prevRequest.current);
      const additionalListenersHaveChanged =
        hasChanged(additionalListeners, prevAdditionalListeners.current);
      // console.log({ newRequest, prevRequest: prevRequest.current, additionalListeners })
      // If a pagination change is in-flight,
      // don't send another request with stale data
      console.log('checking conditions')
      if (newRequestHasChanged) console.log('new request has changed')
      if (newRequestHasStalePagination) console.log('new request has stale pagination')
      if (paginationChangePending.current) console.log('pagination change pending')
      if (additionalListenersHaveChanged) console.log('additional listeners have changed')
      if (newRequestHasStalePagination && !additionalListenersHaveChanged) console.log('REQUEST PREVENTED')
      if (newRequestHasStalePagination && !additionalListenersHaveChanged) return;
      paginationChangePending.current = null;
      if (newRequestHasChanged || additionalListenersHaveChanged) {
        // don't fire the same request twice in a row
        prevRequest.current = newRequest;
        prevAdditionalListeners.current = additionalListeners;
        console.log('FIRING REQUEST')
        dispatch(fetchItems(newRequest));
      } else {
        console.log('REQUEST PREVENTED')
      }
      console.log('end of fetchWithParams')
    };
    let pageOverride;
    const activeFiltersHaveChanged = hasChanged(activeFilters, prevActiveFilters.current);
    const searchQueryHasChanged = hasChanged(searchQuery, prevSearch.current);
    // console.log({ activeFilters })
    if (searchQueryHasChanged) console.log('search query has changed')
    if (activeFiltersHaveChanged) console.log('active filters have changed')
    if (searchQuery && !disableSearch) pageOverride = { search: searchQuery };
    if (!disableSearch && (searchQueryHasChanged || activeFiltersHaveChanged)) {
      // Reset page back to 1 when filter or search changes
      console.log('resetting to page 1')
      prevSearch.current = searchQuery;
      prevActiveFilters.current = activeFilters;
      pageOverride = { search: searchQuery, page: 1 };
    }
    if (pageOverride) {
      paginationChangePending.current = null;
      fetchWithParams(pageOverride);
      paginationChangePending.current = pageOverride;
    } else {
      fetchWithParams();
    }
    console.log('end of spawnFetch')
    console.log('--------')
  }, [
    disableSearch,
    activeFilters,
    dispatch,
    fetchItems,
    paginationParams,
    searchQuery,
    additionalListeners,
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
    paginationChangePending.current = null;
    spawnFetch(pagData);
    paginationChangePending.current = pagData;
  };


  return (
    <>
      <Flex>
        {displaySelectAllCheckbox &&
          <FlexItem alignSelf={{ default: 'alignSelfCenter' }}>
            <SelectAllCheckbox
              {...{
                      selectAll,
                      selectPage,
                      selectNone,
                      selectedCount,
                      pageRowCount,
                    }
                }
              totalCount={total}
              areAllRowsOnPageSelected={areAllRowsOnPageSelected()}
              areAllRowsSelected={areAllRowsSelected()}
            />
          </FlexItem>
        }
        {!disableSearch &&
          <FlexItem>
            <Search
              isDisabled={unresolvedStatusOrNoRows && searchNotUnderway}
              patternfly4
              onSearch={search => updateSearchQuery(search)}
              getAutoCompleteParams={getAutoCompleteParams}
              foremanApiAutoComplete={foremanApiAutoComplete}
            />
          </FlexItem>
        }
        {showActionButtons &&
          <FlexItem style={{ marginLeft: '16px' }}>
            {actionButtons}
          </FlexItem>}
        {showPagination &&
          <PageControls
            variant={PaginationVariant.top}
            total={total}
            page={page}
            perPage={perPage}
            onPaginationUpdate={onPaginationUpdate}
          />
        }
      </Flex>
      {nodesBelowSearch}
      <MainTable
        searchIsActive={!!searchQuery}
        activeFilters={activeFilters}
        rowsCount={pageRowCount}
        emptySearchBody={emptySearchBody}
        {...allTableProps}
      >
        {children}
      </MainTable>
      {showPagination &&
        <Flex>
          <PageControls
            variant={PaginationVariant.bottom}
            total={total}
            page={page}
            perPage={perPage}
            onPaginationUpdate={onPaginationUpdate}
          />
        </Flex>
      }
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
  activeFilters: PropTypes.arrayOf(PropTypes.string),
  displaySelectAllCheckbox: PropTypes.bool,
  selectedCount: PropTypes.number,
  selectAll: PropTypes.func,
  selectNone: PropTypes.func,
  selectPage: PropTypes.func,
  areAllRowsOnPageSelected: PropTypes.func,
  areAllRowsSelected: PropTypes.func,
  emptySearchBody: PropTypes.string,
  disableSearch: PropTypes.bool,
  nodesBelowSearch: PropTypes.node,
};

TableWrapper.defaultProps = {
  metadata: { subtotal: 0 },
  children: null,
  additionalListeners: [],
  activeFilters: [],
  foremanApiAutoComplete: false,
  actionButtons: null,
  displaySelectAllCheckbox: false,
  selectedCount: 0,
  selectAll: noop,
  selectNone: noop,
  selectPage: noop,
  areAllRowsOnPageSelected: noop,
  areAllRowsSelected: noop,
  emptySearchBody: __('Try changing your search settings.'),
  disableSearch: false,
  nodesBelowSearch: null,
};

export default TableWrapper;
