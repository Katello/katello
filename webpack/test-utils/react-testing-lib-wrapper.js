// For react-testing-library helpers, overrides, and utilities
// All elements from react-testing-library can be imported from this wrapper.
// See https://testing-library.com/docs/react-testing-library/setup for more info
import React from 'react';
import thunk from 'redux-thunk';
import Immutable from 'seamless-immutable';
import { APIMiddleware, reducers as apiReducer } from 'foremanReact/redux/API';
import { reducers as fillReducers } from 'foremanReact/components/common/Fill';
import { reducers as foremanModalReducer } from 'foremanReact/components/ForemanModal';
import { STATUS } from 'foremanReact/constants';
import { render, waitFor, waitForElementToBeRemoved } from '@testing-library/react';
import { createStore, applyMiddleware, combineReducers } from 'redux';
import { Provider } from 'react-redux';
import { MemoryRouter, BrowserRouter } from 'react-router-dom';
import { initialSettingsState } from '../scenes/Settings/SettingsReducer';
import allKatelloReducers from '../redux/reducers/index.js';

// r-t-lib's print limit for debug() is quite small, setting it to a much higher char max here.
// See https://github.com/testing-library/react-testing-library/issues/503 for more info.
process.env.DEBUG_PRINT_LIMIT = 99999;

// Renders testable component with redux and react-router according to Katello's usage
// This should be used when you want a fully connected component with Redux state and actions.
function renderWithRedux(
  component,
  {
    apiNamespace, // namespace if using API middleware
    initialApiState = { response: {}, status: STATUS.PENDING }, // Default state for API middleware
    initialState = {}, // Override full state
    routerParams = {},
  } = {},
) {
  // Adding the reducer in the expected namespaced format
  const combinedReducers = combineReducers({
    katello: allKatelloReducers,
    ...apiReducer,
    ...foremanModalReducer,
    ...fillReducers,
  });

  // Namespacing the initial state as well
  const initialFullState = Immutable({
    API: {
      [apiNamespace]: initialApiState,
    },
    katello: {
      settings: {
        settings: initialSettingsState,
      },
    },
    extendable: {},
    ...initialState,
  });
  const middlewares = applyMiddleware(thunk, APIMiddleware);
  const store = createStore(combinedReducers, initialFullState, middlewares);
  const connectedComponent = (
    <Provider store={store}>
      <MemoryRouter {...routerParams} >{component}</MemoryRouter>
    </Provider>
  );

  return { ...render(connectedComponent), store };
}

// When you actually need to change browser history
const renderWithRouter = (ui, { route = '/' } = {}) => {
  window.history.pushState({}, 'Test page', route);

  return render(ui, { wrapper: BrowserRouter });
};

// When the tests run slower, they can hit the default waitFor timeout, which is 1000ms
// There doesn't seem to be a way to set it globally for r-t-lib, so using this wrapper function
const rtlTimeout = 5000;
export const patientlyWaitFor = waitForFunc => waitFor(waitForFunc, { timeout: rtlTimeout });
export const patientlyWaitForRemoval = waitForFunc =>
  waitForElementToBeRemoved(waitForFunc, { timeout: rtlTimeout });

// re-export everything, so the library can be used from this wrapper.
export * from '@testing-library/react';

export { renderWithRedux, renderWithRouter };
