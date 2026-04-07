import React from 'react';
import { render, act } from '@testing-library/react';

import { LoadingState } from './index';

jest.useFakeTimers();

const loadingComponent = (
  <LoadingState loading loadingText="Loading">
    <p>Loading Complete</p>
  </LoadingState>
);

test('Loading State renders children when not loading', () => {
  const notLoadingComponent = (
    <LoadingState loading={false} loadingText="Loading">
      <p>Loading Complete</p>
    </LoadingState>
  );
  const { getByText } = render(notLoadingComponent);

  act(() => { jest.runAllTimers(); });

  expect(getByText('Loading Complete')).toBeInTheDocument();
});

test('Loading State renders nothing before timeout when loading', () => {
  const { container } = render(loadingComponent);

  expect(container.innerHTML).toBe('');

  act(() => { jest.runAllTimers(); });
});

test('Loading State renders spinner after timeout when loading', () => {
  const { getByText, queryByText } = render(loadingComponent);

  act(() => { jest.runAllTimers(); });

  expect(getByText('Loading')).toBeInTheDocument();
  expect(queryByText('Loading Complete')).not.toBeInTheDocument();
});
