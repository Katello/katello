import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';
import TooltipButton from './TooltipButton';

const createRequiredProps = () => ({
  tooltipId: 'some-id',
});

const fixtures = {
  'renders minimal TooltipButton': { ...createRequiredProps() },
  'renders disabled TooltipButton': {
    ...createRequiredProps(),
    disabled: true,
    title: 'some-title',
    tooltipPlacement: 'top',
    tooltipText: 'some-text',
  },
  'renders disabled TooltipButton with renderedButton': {
    ...createRequiredProps(),
    disabled: true,
    renderedButton: 'some-render-button',
    tooltipPlacement: 'top',
    tooltipText: 'some-text',
  },
  'renders enabled TooltipButton': {
    ...createRequiredProps(),
    disabled: false,
    title: 'some-title',
  },
  'renders enabled TooltipButton with renderedButton': {
    ...createRequiredProps(),
    disabled: false,
    renderedButton: 'some-render-button',
  },
};

describe('TooltipButton', () =>
  testComponentSnapshotsWithFixtures(TooltipButton, fixtures));
