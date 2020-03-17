// For react-testing-library helpers, overrides, and utilities
// All elements from react-testing-library can be imported from this wrapper.
// See https://testing-library.com/docs/react-testing-library/setup for more info
import React from 'react';
import thunk from 'redux-thunk';
import Immutable from 'seamless-immutable';
import { reducers as apiReducer } from 'foremanReact/redux/API';
import { STATUS } from 'foremanReact/constants';
import { render } from '@testing-library/react';
import { createStore, applyMiddleware, combineReducers } from 'redux';
import { Provider } from 'react-redux';
import { MemoryRouter } from 'react-router-dom';
import { APIMiddleware } from 'foremanReact/redux/middlewares';

// Renders testable component with redux and react-router according to Katello's usage
// This should be used when you want a fully connected component with Redux state and actions.
function renderWithApiRedux(
  component,
  {
    namespace, // redux namespace
    initialState = { response: {}, status: STATUS.RESOLVED },
  } = {},
) {
  // Adding the reducer in the expected namespaced format
  const combinedReducers = combineReducers({ ...apiReducer });
  // Namespacing the initial state as well
  const initialFullState = Immutable({ API: { [namespace]: initialState } });
  const middlewares = applyMiddleware(thunk, APIMiddleware);
  const store = createStore(combinedReducers, initialFullState, middlewares);
  const connectedComponent = (
    <Provider store={store}>
      <MemoryRouter>{component}</MemoryRouter>
    </Provider>
  );

  return { ...render(connectedComponent), store };
}

// re-export everything, so the library can be used from this wrapper.
export * from '@testing-library/react';

export { renderWithApiRedux };
