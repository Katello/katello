import React from 'react';
import { renderWithRedux, patientlyWaitFor } from 'react-testing-lib-wrapper';
import EmptyStateMessage from '../EmptyStateMessage';

describe('EmptyStateMessage', () => {
  test('Shows clear search link when there are no results', async (done) => {
    const { getByText } = renderWithRedux(<EmptyStateMessage
      title="empty content title"
      body="empty content body"
      search
      searchIsActive
    />);

    // Verify that the clear search link is visible
    await patientlyWaitFor(() => expect(getByText('Clear search')).toBeInTheDocument());

    done();
  });

  test('Shows clear filters link when there are no results', async (done) => {
    const { getByText } = renderWithRedux(<EmptyStateMessage
      title="empty content title"
      body="empty content body"
      search
      filtersAreActive
      activeFilters={['foo']}
      resetFilters={jest.fn()}
    />);

    // Verify that the clear filters link is visible
    await patientlyWaitFor(() => expect(getByText('Clear filters')).toBeInTheDocument());

    done();
  });

  test('Handles override of secondaryActionText', async (done) => {
    const { getByText } = renderWithRedux(<EmptyStateMessage
      title="empty content title"
      body="empty content body"
      resetFilters={jest.fn()}
      showSecondaryActionButton
      secondaryActionTextOverride="Custom text"
    />);

    // Verify that the custom text is visible
    await patientlyWaitFor(() => expect(getByText('Custom text')).toBeInTheDocument());

    done();
  });
});

