import React from 'react';
import { fireEvent } from '@testing-library/react';
import { renderWithRedux } from 'react-testing-lib-wrapper';
import PullablePathsModal from '../PullablePathsModal';
import manifestDetailsData from '../Details/__tests__/manifestDetails.fixtures.json';

describe('PullablePathsModal', () => {
  const mockRepositories = manifestDetailsData.repositories;

  const mockSetIsOpen = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('renders modal when show is true', () => {
    const { getByText } = renderWithRedux(<PullablePathsModal
      show
      setIsOpen={mockSetIsOpen}
      repositories={mockRepositories}
      tagName="v1.0"
    />);

    expect(getByText('Copy pullable paths')).toBeInTheDocument();
  });

  test('does not render modal when show is false', () => {
    const { queryByText } = renderWithRedux(<PullablePathsModal
      show={false}
      setIsOpen={mockSetIsOpen}
      repositories={mockRepositories}
      tagName="v1.0"
    />);

    expect(queryByText('Copy pullable paths')).not.toBeInTheDocument();
  });

  test('displays description text', () => {
    const { getByText } = renderWithRedux(<PullablePathsModal
      show
      setIsOpen={mockSetIsOpen}
      repositories={mockRepositories}
      tagName="v1.0"
    />);

    expect(getByText(/Copy this to pull the specific image version from your published content view/)).toBeInTheDocument();
  });

  test('renders ManifestRepositoriesTable with correct props', () => {
    const { getByText } = renderWithRedux(<PullablePathsModal
      show
      setIsOpen={mockSetIsOpen}
      repositories={mockRepositories}
      tagName="v1.0"
    />);

    expect(getByText('Environment')).toBeInTheDocument();
    expect(getByText('Content view')).toBeInTheDocument();
    expect(getByText('Repository')).toBeInTheDocument();
    expect(getByText('Pullable path')).toBeInTheDocument();
  });

  test('close button calls setIsOpen with false', () => {
    const { getByText } = renderWithRedux(<PullablePathsModal
      show
      setIsOpen={mockSetIsOpen}
      repositories={mockRepositories}
      tagName="v1.0"
    />);

    const closeButton = getByText('Close');
    fireEvent.click(closeButton);

    expect(mockSetIsOpen).toHaveBeenCalledWith(false);
    expect(mockSetIsOpen).toHaveBeenCalledTimes(1);
  });

  test('modal close (X button) calls setIsOpen with false', () => {
    const { container } = renderWithRedux(<PullablePathsModal
      show
      setIsOpen={mockSetIsOpen}
      repositories={mockRepositories}
      tagName="v1.0"
    />);

    const closeButton = container.querySelector('button[aria-label="Close"]');
    if (closeButton) {
      fireEvent.click(closeButton);
      expect(mockSetIsOpen).toHaveBeenCalledWith(false);
    }
  });

  test('handles empty repositories array', () => {
    const { getByText } = renderWithRedux(<PullablePathsModal
      show
      setIsOpen={mockSetIsOpen}
      repositories={[]}
      tagName="v1.0"
    />);

    expect(getByText('Copy pullable paths')).toBeInTheDocument();
    expect(getByText('Environment')).toBeInTheDocument();
  });

  test('handles undefined repositories', () => {
    const { getByText } = renderWithRedux(<PullablePathsModal
      show
      setIsOpen={mockSetIsOpen}
      repositories={undefined}
      tagName="v1.0"
    />);

    expect(getByText('Copy pullable paths')).toBeInTheDocument();
  });

  test('displays repositories data in table', () => {
    const { getAllByText, getByText } = renderWithRedux(<PullablePathsModal
      show
      setIsOpen={mockSetIsOpen}
      repositories={mockRepositories}
      tagName="v1.0"
    />);

    expect(getAllByText('Library')[0]).toBeInTheDocument();
    expect(getByText('Default Organization View 1.0')).toBeInTheDocument();
    expect(getAllByText('ubi9-container')[0]).toBeInTheDocument();
  });
});
