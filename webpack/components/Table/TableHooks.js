import { useState, useRef, useEffect, useCallback } from 'react';
import { isEmpty } from 'lodash';

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

export const useSelectionSet = (results, metadata, initialArry = [], idColumn = 'id') => {
  const selectionSet = useSet(initialArry);
  const pageIds = results?.map(result => result[idColumn]) ?? [];
  const areAllRowsOnPageSelected = () => Number(pageIds?.length) > 0 &&
                                         pageIds.every(result => selectionSet.has(result));

  const areAllRowsSelected = () =>
    Number(selectionSet.size) > 0 && selectionSet.size === Number(metadata.total);

  const selectPage = () => selectionSet.addAll(pageIds);
  const selectNone = () => selectionSet.clear();
  const selectOne = (isSelected, id) => {
    if (isSelected) {
      selectionSet.add(id);
    } else {
      selectionSet.delete(id);
    }
  };

  const selectedCount = selectionSet.size;

  const isSelected = id => selectionSet.has(id);

  return {
    selectOne,
    selectedCount,
    areAllRowsOnPageSelected,
    areAllRowsSelected,
    selectPage,
    selectNone,
    isSelected,
    selectionSet,
  };
};

const usePrevious = (value) => {
  const ref = useRef();
  useEffect(() => {
    ref.current = value;
  });
  return ref.current;
};

export const useBulkSelect = (results, metadata, initialArry = [], idColumn = 'id') => {
  const { selectionSet: inclusionSet, ...selectOptions } =
                useSelectionSet(results, metadata, initialArry, idColumn);
  const exclusionSet = useSet([]);
  const [searchQuery, updateSearchQuery] = useState('');
  const [selectAllMode, setSelectAllMode] = useState(false);
  const selectedCount = selectAllMode ?
    Number(metadata.subtotal) - exclusionSet.size : selectOptions.selectedCount;

  const areAllRowsOnPageSelected = () => selectAllMode ||
                                         selectOptions.areAllRowsOnPageSelected();

  const areAllRowsSelected = () => (selectAllMode && exclusionSet.size === 0) ||
                                   selectOptions.areAllRowsSelected();

  const isSelected = (id) => {
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
  }, [exclusionSet, inclusionSet]);

  const selectOne = (isRowSelected, id) => {
    if (selectAllMode) {
      if (isRowSelected) {
        exclusionSet.delete(id);
      } else {
        exclusionSet.add(id);
      }
    } else {
      selectOptions.selectOne(isRowSelected, id);
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

  const fetchBulkParams = () => {
    const selected = {
      included: {
        ids: [],
        search: null,
      },
      excluded: {
        ids: [],
      },
      all: false,
    };

    if (selectAllMode) {
      selected.included.search = searchQuery;
      selected.excluded.ids = [...exclusionSet];
      selected.all = true;
    } else if (!isEmpty(inclusionSet)) {
      selected.included.ids = [...inclusionSet];
    } else {
      return {};
    }
    return selected;
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
