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
  toggleGroup,
  children,
  metadata,
  fetchItems,
  autocompleteEndpoint,
  foremanApiAutoComplete,
  searchQuery,
  updateSearchQuery,
  searchPlaceholderText,
  additionalListeners,
  activeFilters,
  displaySelectAllCheckbox,
  selectAll,
  selectAllMode,
  selectNone,
  selectPage,
  areAllRowsOnPageSelected,
  areAllRowsSelected,
  selectedCount,
  selectedResults,
  clearSelectedResults,
  emptySearchBody,
  disableSearch,
  nodesBelowSearch,
  bookmarkController,
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
  const resolvedStatusNoContent =
    !searchQuery && allTableProps.status === STATUS.RESOLVED && pageRowCount === 0;
  const showPagination = !unresolvedStatusOrNoRows;
  const showActionButtons = actionButtons && !unresolvedStatus;
  const showToggleGroup = toggleGroup && !unresolvedStatus;
  const paginationParams = useCallback(() =>
    ({ per_page: perPage, page }), [perPage, page]);
  const prevRequest = useRef({});
  const prevSearch = useRef('');
  const prevAdditionalListeners = useRef([]);
  const prevActiveFilters = useRef([]);
  const paginationChangePending = useRef(null);

  const hasChanged = (oldValue, newValue) => !isEqual(oldValue, newValue);

  const spawnFetch = useCallback((paginationData) => {
    const fetchWithParams = (allParams = {}) => {
      const newRequest = {
        ...(paginationData ?? paginationParams()),
        ...allParams,
      };
      const pagParamsHaveChanged = (newPagParams, oldPagParams) =>
        (newPagParams.page && hasChanged(newPagParams.page, oldPagParams.page)) ||
        (newPagParams.per_page && hasChanged(newPagParams.per_page, oldPagParams.per_page));
      const newRequestHasStalePagination = !!(paginationChangePending.current &&
        pagParamsHaveChanged(newRequest, paginationChangePending.current));
      const newRequestHasChanged = hasChanged(newRequest, prevRequest.current);
      const additionalListenersHaveChanged =
        hasChanged(additionalListeners, prevAdditionalListeners.current);
      // If a pagination change is in-flight,
      // don't send another request with stale data
      if (newRequestHasStalePagination && !additionalListenersHaveChanged) return;
      paginationChangePending.current = null;
      if (newRequestHasChanged || additionalListenersHaveChanged) {
        // don't fire the same request twice in a row
        prevRequest.current = newRequest;
        prevAdditionalListeners.current = additionalListeners;
        dispatch(fetchItems(newRequest));
      }
    };
    let paramsOverride;
    const activeFiltersHaveChanged = hasChanged(activeFilters, prevActiveFilters.current);
    const searchQueryHasChanged = hasChanged(searchQuery, prevSearch.current);
    if (searchQuery && !disableSearch) paramsOverride = { search: searchQuery };
    if (!disableSearch && (searchQueryHasChanged || activeFiltersHaveChanged)) {
      // Reset page back to 1 when filter or search changes
      prevSearch.current = searchQuery;
      prevActiveFilters.current = activeFilters;
      paramsOverride = { search: searchQuery, page: 1 };
    }
    if (paramsOverride) {
      // paramsOverride may have both page and search, or just search
      const pageOverride = !!paramsOverride.page;
      if (pageOverride) paginationChangePending.current = null;
      fetchWithParams(paramsOverride);
      if (pageOverride) paginationChangePending.current = paramsOverride;
    } else {
      fetchWithParams();
    }
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
      <Flex style={{ alignItems: 'center' }} className="margin-16-24">
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
              totalCount={Number(metadata?.selectable ?? total)}
              areAllRowsOnPageSelected={areAllRowsOnPageSelected()}
              areAllRowsSelected={areAllRowsSelected()}
            />
          </FlexItem>
        }
        {!disableSearch && !resolvedStatusNoContent &&
          <FlexItem>
            <Search
              isDisabled={unresolvedStatusOrNoRows && !searchQuery}
              patternfly4
              initialInputValue={searchQuery && searchQuery}
              onSearch={search => updateSearchQuery(search)}
              getAutoCompleteParams={getAutoCompleteParams}
              foremanApiAutoComplete={foremanApiAutoComplete}
              bookmarkController={bookmarkController}
              placeholder={searchPlaceholderText}
            />
          </FlexItem>
        }
        {showToggleGroup &&
          <FlexItem>
            {toggleGroup}
          </FlexItem>}
        {showActionButtons &&
          <FlexItem>
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
      {nodesBelowSearch &&
        <Flex className="margin-16-24 gap-16" style={{ alignItems: 'center' }}>
          {nodesBelowSearch}
        </Flex>
      }
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
    selectable: PropTypes.number,
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
  searchPlaceholderText: PropTypes.string,
  actionButtons: PropTypes.node,
  toggleGroup: PropTypes.node,
  children: PropTypes.node,
  // additionalListeners are anything that can trigger another API call, e.g. a filter
  additionalListeners: PropTypes.arrayOf(PropTypes.oneOfType([
    PropTypes.number,
    PropTypes.string,
    PropTypes.bool,
  ])),
  activeFilters: PropTypes.arrayOf(PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.arrayOf(PropTypes.string),
  ])),
  defaultFilters: PropTypes.arrayOf(PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.arrayOf(PropTypes.string),
  ])),
  displaySelectAllCheckbox: PropTypes.bool,
  selectedCount: PropTypes.number,
  selectedResults: PropTypes.arrayOf(PropTypes.shape({})),
  clearSelectedResults: PropTypes.func,
  selectAll: PropTypes.func,
  selectAllMode: PropTypes.bool,
  selectNone: PropTypes.func,
  selectPage: PropTypes.func,
  areAllRowsOnPageSelected: PropTypes.func,
  areAllRowsSelected: PropTypes.func,
  emptySearchBody: PropTypes.string,
  disableSearch: PropTypes.bool,
  nodesBelowSearch: PropTypes.node,
  bookmarkController: PropTypes.string,
};

TableWrapper.defaultProps = {
  metadata: { subtotal: 0, selectable: 0 },
  children: null,
  additionalListeners: [],
  activeFilters: [],
  defaultFilters: [],
  foremanApiAutoComplete: false,
  searchPlaceholderText: undefined,
  actionButtons: null,
  toggleGroup: null,
  displaySelectAllCheckbox: false,
  selectedCount: 0,
  selectedResults: [],
  clearSelectedResults: noop,
  selectAll: undefined,
  selectAllMode: false,
  selectNone: undefined,
  selectPage: undefined,
  areAllRowsOnPageSelected: noop,
  areAllRowsSelected: noop,
  emptySearchBody: __('Try changing your search settings.'),
  disableSearch: false,
  nodesBelowSearch: null,
  bookmarkController: undefined,
};

export default TableWrapper;
