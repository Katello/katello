import { useState, useRef, useEffect, useCallback } from 'react';
import { isEmpty } from 'lodash';
import { useLocation } from 'react-router-dom';
import { friendlySearchParam } from '../../utils/helpers';

class ReactConnectedSet extends Set {
  constructor(initialValue, forceRender) {
    super();
    this.forceRender = forceRender;
    // The constructor would normally call add() with the initial value, but since we
    // must call super() at the top, this.forceRender() isn't defined yet.
    // So, we call super() above with no argument, then call add() manually below
    // after forceRender is defined
    if (initialValue) {
      if (initialValue.constructor.name === 'Array') {
        initialValue.forEach(id => super.add(id));
      } else {
        super.add(initialValue);
      }
    }
  }

  add(value) {
    const result = super.add(value); // ensuring these methods have the same API as the superclass
    this.forceRender();
    return result;
  }

  clear() {
    const result = super.clear();
    this.forceRender();
    return result;
  }

  delete(value) {
    const result = super.delete(value);
    this.forceRender();
    return result;
  }

  onToggle(isOpen, id) {
    if (isOpen) {
      this.add(id);
    } else {
      this.delete(id);
    }
  }

  addAll(ids) {
    ids.forEach(id => super.add(id));
    this.forceRender();
  }
}

export const useSet = (initialArry) => {
  const [, setToggle] = useState(0);
  // needed because mutating a Ref won't cause React to rerender
  const forceRender = () => setToggle(prev => prev + 1);
  const set = useRef(new ReactConnectedSet(initialArry, forceRender));
  return set.current;
};

export const useSelectionSet = ({
  results, metadata,
  initialArry = [],
  idColumn = 'id',
  isSelectable = () => true,
}) => {
  const selectionSet = useSet(initialArry);
  const pageIds = results?.map(result => result[idColumn]) ?? [];
  const selectableResults = results?.filter(result => isSelectable(result)) ?? [];
  const selectableIds = new Set(selectableResults.map(result => result[idColumn]));
  const selectedResults = useRef({}); // { id: result }
  const canSelect = id => selectableIds.has(id);
  const areAllRowsOnPageSelected = () =>
    Number(pageIds?.length) > 0 &&
        pageIds.every(result => selectionSet.has(result) || !canSelect(result));

  const areAllRowsSelected = () =>
    Number(selectionSet.size) > 0 && selectionSet.size === Number(metadata.selectable);

  const selectPage = () => {
    const selectablePageIds = pageIds.filter(canSelect);
    selectionSet.addAll(selectablePageIds);
    // eslint-disable-next-line no-restricted-syntax
    for (const result of selectableResults) {
      selectedResults.current[result[idColumn]] = result;
    }
  };
  const clearSelectedResults = () => {
    selectedResults.current = {};
  };
  const selectNone = () => {
    selectionSet.clear();
    clearSelectedResults();
  };
  const selectOne = (isSelected, id, data) => {
    if (canSelect(id)) {
      if (isSelected) {
        if (data) selectedResults.current[id] = data;
        selectionSet.add(id);
      } else {
        delete selectedResults.current[id];
        selectionSet.delete(id);
      }
    }
  };

  const selectedCount = selectionSet.size;

  const isSelected = id => canSelect(id) && selectionSet.has(id);

  return {
    selectOne,
    selectedCount,
    areAllRowsOnPageSelected,
    areAllRowsSelected,
    selectPage,
    selectNone,
    isSelected,
    isSelectable: canSelect,
    selectionSet,
    selectedResults: Object.values(selectedResults.current),
    clearSelectedResults,
  };
};

const usePrevious = (value) => {
  const ref = useRef();
  useEffect(() => {
    ref.current = value;
  });
  return ref.current;
};

export const useBulkSelect = ({
  results,
  metadata,
  initialArry = [],
  initialSearchQuery = '',
  idColumn = 'id',
  isSelectable,
}) => {
  const { selectionSet: inclusionSet, ...selectOptions } =
                useSelectionSet({
                  results, metadata, initialArry, idColumn, isSelectable,
                });
  const exclusionSet = useSet([]);
  const [searchQuery, updateSearchQuery] = useState(initialSearchQuery);
  const [selectAllMode, setSelectAllMode] = useState(false);
  const selectedCount = selectAllMode ?
    Number(metadata.selectable) - exclusionSet.size : selectOptions.selectedCount;

  const areAllRowsOnPageSelected = () => selectAllMode ||
                                         selectOptions.areAllRowsOnPageSelected();

  const areAllRowsSelected = () => (selectAllMode && exclusionSet.size === 0) ||
                                   selectOptions.areAllRowsSelected();

  const isSelected = (id) => {
    if (!selectOptions.isSelectable(id)) {
      return false;
    }
    if (selectAllMode) {
      return !exclusionSet.has(id);
    }
    return inclusionSet.has(id);
  };

  const selectPage = () => {
    setSelectAllMode(false);
    selectOptions.selectPage();
  };

  const selectNone = useCallback(() => {
    setSelectAllMode(false);
    exclusionSet.clear();
    inclusionSet.clear();
    selectOptions.clearSelectedResults();
  }, [exclusionSet, inclusionSet, selectOptions]);

  const selectOne = (isRowSelected, id, data) => {
    if (selectAllMode) {
      if (isRowSelected) {
        exclusionSet.delete(id);
      } else {
        exclusionSet.add(id);
      }
    } else {
      selectOptions.selectOne(isRowSelected, id, data);
    }
  };

  const selectAll = (checked) => {
    setSelectAllMode(checked);
    if (checked) {
      exclusionSet.clear();
    } else {
      inclusionSet.clear();
    }
  };

  const fetchBulkParams = (idColumnName = idColumn) => {
    const searchQueryWithExclusionSet = () => {
      const query = [searchQuery,
        !isEmpty(exclusionSet) && `${idColumnName} !^ (${[...exclusionSet].join(',')})`];
      return query.filter(item => item).join(' and ');
    };

    const searchQueryWithInclusionSet = () => {
      if (isEmpty(inclusionSet)) throw new Error('Cannot build a search query with no items selected');
      return `${idColumnName} ^ (${[...inclusionSet].join(',')})`;
    };

    return selectAllMode ? searchQueryWithExclusionSet() : searchQueryWithInclusionSet();
  };

  const prevSearchRef = usePrevious({ searchQuery });

  useEffect(() => {
    // if search value changed and cleared from a string to empty value
    // And it was select all -> then reset selections
    if ((prevSearchRef && !isEmpty(prevSearchRef.searchQuery)) &&
        isEmpty(searchQuery) && selectAllMode) {
      selectNone();
    }
  }, [searchQuery, selectAllMode, prevSearchRef, selectNone]);

  return {
    ...selectOptions,
    selectPage,
    selectNone,
    selectAll,
    selectAllMode,
    isSelected,
    selectedCount,
    fetchBulkParams,
    searchQuery,
    updateSearchQuery,
    selectOne,
    areAllRowsOnPageSelected,
    areAllRowsSelected,
  };
};

// takes a url query like ?type=security&search=name+~+foo
// and returns an object
// {
//   type: 'security',
//   searchParam: 'name ~ foo'
// }
export const useUrlParams = () => {
  const location = useLocation();
  const { search: urlSearchParam, ...urlParams }
    = Object.fromEntries(new URLSearchParams(location.search).entries());
  const searchParam = urlSearchParam ? friendlySearchParam(urlSearchParam) : '';
  return {
    searchParam,
    ...urlParams,
  };
};

export const useTableSort = ({
  allColumns,
  columnsToSortParams,
  initialSortColumnName = allColumns[0],
}) => {
  if (!Object.keys(columnsToSortParams).includes(initialSortColumnName)) {
    throw new Error(`initialSortColumnName '${initialSortColumnName}' must also be defined in columnsToSortParams`);
  }
  const [activeSortColumn, setActiveSortColumn] = useState(initialSortColumnName);
  const [activeSortDirection, setActiveSortDirection] = useState('asc');

  const onSort = (_event, index, direction) => {
    setActiveSortColumn(allColumns?.[index]);
    setActiveSortDirection(direction);
  };

  const pfSortParams = (columnName, newSortColIndex) => ({
    columnIndex: newSortColIndex ?? allColumns?.indexOf(columnName),
    sortBy: {
      defaultDirection: 'asc',
      direction: activeSortDirection,
      index: allColumns?.indexOf(activeSortColumn),
    },
    onSort,
  });

  return {
    pfSortParams,
    apiSortParams: {
      sort_by: columnsToSortParams[activeSortColumn],
      sort_order: activeSortDirection,
    },
    activeSortColumn,
    activeSortDirection,
  };
};
