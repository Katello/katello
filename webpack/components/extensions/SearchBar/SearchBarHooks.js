import { useEffect, useCallback, useRef } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { selectSearchBarClearSearch } from './SearchBarSelectors';

export const useClearSearch = ({
  updateSearchQuery,
}) => {
  const dispatch = useDispatch();
  // We keep the clearSearch function in Redux to avoid prop drilling and make EmptyStateMessage
  // more reusable both with and without TableWrapper.
  const existingClearSearch = useSelector(selectSearchBarClearSearch);
  // In Katello we don't have access to Foreman <SearchBar /> component's internal state,
  // so we don't have an easy way to clear the search input. We can use a counter to
  // pass as a key prop to the <SearchBar /> component, which will force it to reset
  // its internal state when clearSearch is called.
  const counter = useRef(0);

  const clearSearch = useCallback(() => {
    counter.current += 1; // reset the text input
    if (typeof updateSearchQuery !== 'function') {
      // eslint-disable-next-line no-console
      console.error('You must pass the updateSearchQuery function to useClearSearch');
      return;
    }
    updateSearchQuery(''); // make a new API call with blank search query
  }, [updateSearchQuery]);

  useEffect(() => {
    if (typeof existingClearSearch !== 'function') {
      dispatch({
        type: 'SET_CLEAR_SEARCH',
        payload: clearSearch,
      });
    }
  }, [dispatch, existingClearSearch, clearSearch]);

  // eslint-disable-next-line arrow-body-style
  useEffect(() => {
    return function cleanupClearSearch() {
      dispatch({
        type: 'SET_CLEAR_SEARCH',
        payload: {},
      });
    };
  }, [dispatch]);

  return counter.current;
};

export default useClearSearch;
