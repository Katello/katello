import React from 'react';
import { render } from '@testing-library/react';
import TooltipButton from './TooltipButton';

test('TooltipButton renders minimal button when not disabled', () => {
  const { container } = render(<TooltipButton tooltipId="some-id" />);
  const button = container.querySelector('button');
  expect(button).toBeInTheDocument();
  expect(button).not.toBeDisabled();
});

test('TooltipButton renders disabled button with title and tooltip wrapper', () => {
  const { getByText } = render(<TooltipButton
    tooltipId="some-id"
    disabled
    title="some-title"
    tooltipPlacement="top"
    tooltipText="some-text"
  />);

  expect(getByText('some-title')).toBeInTheDocument();
  const button = getByText('some-title').closest('button');
  expect(button).toBeDisabled();
});

test('TooltipButton renders disabled with renderedButton', () => {
  const { getByText } = render(<TooltipButton
    tooltipId="some-id"
    disabled
    renderedButton="some-render-button"
    tooltipPlacement="top"
    tooltipText="some-text"
  />);

  expect(getByText('some-render-button')).toBeInTheDocument();
});

test('TooltipButton renders enabled button with title', () => {
  const { getByText } = render(<TooltipButton
    tooltipId="some-id"
    disabled={false}
    title="some-title"
  />);

  expect(getByText('some-title')).toBeInTheDocument();
});

test('TooltipButton renders enabled with renderedButton', () => {
  const { getByText } = render(<TooltipButton
    tooltipId="some-id"
    disabled={false}
    renderedButton="some-render-button"
  />);

  expect(getByText('some-render-button')).toBeInTheDocument();
});
