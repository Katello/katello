import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import LabelsAnnotationsModal from '../../LabelsAnnotationsModal';

describe('LabelsAnnotationsModal', () => {
  const mockSetIsOpen = jest.fn();
  const defaultProps = {
    show: true,
    setIsOpen: mockSetIsOpen,
    digest: 'sha256:abcd1234',
    labels: {},
    annotations: {},
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders and closes modal correctly', () => {
    const { rerender } = render(<LabelsAnnotationsModal {...defaultProps} />);

    expect(screen.getByText('Labels and annotations')).toBeInTheDocument();
    expect(screen.getByText('sha256:abcd1234')).toBeInTheDocument();

    // Close modal
    const closeButton = screen.getByText('Close');
    fireEvent.click(closeButton);
    expect(mockSetIsOpen).toHaveBeenCalledWith(false);

    // Modal hidden when show is false
    rerender(<LabelsAnnotationsModal {...defaultProps} show={false} />);
    expect(screen.queryByText('Labels and annotations')).not.toBeInTheDocument();
  });

  it('displays labels and annotations with pagination', () => {
    // Test with small number of items
    const labels = { app: 'myapp', env: 'prod' };
    const annotations = { version: '1.0.0' };
    const { rerender } = render(<LabelsAnnotationsModal
      {...defaultProps}
      labels={labels}
      annotations={annotations}
    />);

    expect(screen.getByText('app=myapp')).toBeInTheDocument();
    expect(screen.getByText('env=prod')).toBeInTheDocument();
    expect(screen.getByText('version=1.0.0')).toBeInTheDocument();
    expect(screen.getByText('3 labels and annotations')).toBeInTheDocument();

    // Test with more than 10 items to trigger pagination
    const manyLabels = {};
    for (let i = 1; i <= 15; i += 1) {
      manyLabels[`label${i}`] = `value${i}`;
    }
    rerender(<LabelsAnnotationsModal {...defaultProps} labels={manyLabels} />);

    // Initially shows first 10 items
    expect(screen.getByText('label1=value1')).toBeInTheDocument();
    expect(screen.getByText('label10=value10')).toBeInTheDocument();
    expect(screen.queryByText('label11=value11')).not.toBeInTheDocument();
    expect(screen.getByText('Show 5 more')).toBeInTheDocument();

    // Click to show all
    fireEvent.click(screen.getByText('Show 5 more'));
    expect(screen.getByText('label15=value15')).toBeInTheDocument();
    expect(screen.queryByText('Show 5 more')).not.toBeInTheDocument();
  });
});
