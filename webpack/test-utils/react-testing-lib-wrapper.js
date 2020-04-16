// For react-testing-library helpers, overrides, and utilities
// All elements from react-testing-library can be imported from this wrapper.
// See https://testing-library.com/docs/react-testing-library/setup for more info
import React from 'react';
import thunk from 'redux-thunk';
import Immutable from 'seamless-immutable';
import { render } from '@testing-library/react';
import { createStore, applyMiddleware, combineReducers } from 'redux';
import { Provider } from 'react-redux';
import { MemoryRouter } from 'react-router-dom';

// Renders testable component with redux and react-router according to Katello's usage
// This should be used when you want a fully connected component with Redux state and actions.
function renderWithKatelloRedux(
  component,
  {
    namespace, // redux namespace
    reducer,
    initialState = {},
  } = {},
) {
  // Adding the reducer in the expected namespaced format
  const combinedReducers = combineReducers({ katello: combineReducers({ [namespace]: reducer }) });
  // Namespacing the initial state as well
  const initialKatelloState = Immutable({ katello: { [namespace]: initialState } });
  const store = createStore(combinedReducers, initialKatelloState, applyMiddleware(thunk));
  const connectedComponent = (
    <Provider store={store}>
      <MemoryRouter>{component}</MemoryRouter>
    </Provider>
  );

  return { ...render(connectedComponent), store };
}

// re-export everything, so the library can be used from this wrapper.
export * from '@testing-library/react';

export { renderWithKatelloRedux };
