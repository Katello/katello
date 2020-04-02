// For react-testing-library helpers, overrides, and utilities
// See https://testing-library.com/docs/react-testing-library/setup for more info
import React from 'react';
import { render } from '@testing-library/react';
import { createStore } from 'redux';
import { Provider } from 'react-redux';

function renderWithRedux(
  component,
  reducer,
  initialState,
) {
  const store = createStore(reducer, initialState);
  return {
    ...render(<Provider store={store}>{component}</Provider>),
  };
}

// re-export everything
export * from '@testing-library/react';

export { renderWithRedux };
