// For react-testing-library helpers, overrides, and utilities
// See https://testing-library.com/docs/react-testing-library/setup for more info
import React from 'react';
import thunk from 'redux-thunk';
import Immutable from 'seamless-immutable';
import { render } from '@testing-library/react';
import { createStore, applyMiddleware, combineReducers } from 'redux';
import { Provider } from 'react-redux';
import { Router } from 'react-router-dom';
import { createMemoryHistory } from 'history';

// Renders testable component with redux and react-router according to our usage
function katelloRender(
  component,
  {
    namespace, // redux namespace
    reducer,
    initialState = {},
    route = '/',
    history = createMemoryHistory({ initialEntries: [route] }),
  } = {},
) {
  // Adding the reducer in the expected namespaced format
  const combinedReducers = combineReducers({ katello: combineReducers({ [namespace]: reducer }) });
  // Namespacing the initial state as well
  const initialKatelloState = Immutable({ katello: { [namespace]: initialState } });
  const store = createStore(combinedReducers, initialKatelloState, applyMiddleware(thunk));

  return {
    ...render(<Provider store={store}><Router history={history}>{component}</Router></Provider>),
    store,
    history,
  };
}

// re-export everything
export * from '@testing-library/react';

export { katelloRender };
