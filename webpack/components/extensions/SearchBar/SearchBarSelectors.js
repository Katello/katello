export const selectSearchBarState = state =>
  state.katello.searchBar;

export const selectSearchBarClearSearch = state =>
  selectSearchBarState(state)?.clearSearch;
