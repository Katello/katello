import React from 'react';
import { renderWithRedux, fireEvent } from 'react-testing-lib-wrapper';
import { PaginationVariant } from '@patternfly/react-core';

import PageControls from '../PageControls';

const renderControls = (props) => {
  const onPaginationUpdate = jest.fn();
  const view = renderWithRedux(<PageControls
    variant={PaginationVariant.bottom}
    onPaginationUpdate={onPaginationUpdate}
    {...props}
  />);
  return { ...view, onPaginationUpdate };
};

describe('PageControls', () => {
  test('can move back to page 1 when one entry is shown per page', () => {
    const { getByRole, onPaginationUpdate } = renderControls({
      total: 2,
      page: 2,
      perPage: 1,
    });

    const previous = getByRole('button', { name: 'Go to previous page' });
    expect(previous).toBeEnabled();
    expect(getByRole('button', { name: 'Go to first page' })).toBeEnabled();

    fireEvent.click(previous);
    expect(onPaginationUpdate).toHaveBeenCalledWith({ page: 1, per_page: 1 });
  });

  test('keeps the previous control enabled on a later page', () => {
    const { getByRole } = renderControls({
      total: 5,
      page: 3,
      perPage: 1,
    });

    expect(getByRole('button', { name: 'Go to previous page' })).toBeEnabled();
    expect(getByRole('button', { name: 'Go to next page' })).toBeEnabled();
  });

  test('disables the previous control on the first page', () => {
    const { getByRole } = renderControls({
      total: 2,
      page: 1,
      perPage: 1,
    });

    expect(getByRole('button', { name: 'Go to previous page' })).toBeDisabled();
    expect(getByRole('button', { name: 'Go to first page' })).toBeDisabled();
    expect(getByRole('button', { name: 'Go to next page' })).toBeEnabled();
  });
});
