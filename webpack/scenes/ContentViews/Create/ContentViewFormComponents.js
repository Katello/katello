import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { OutlinedQuestionCircleIcon } from '@patternfly/react-icons';
import { Tooltip, TooltipPosition, Flex, FlexItem } from '@patternfly/react-core';
import { autoPublishHelpText, dependenciesHelpText, importOnlyHelpText, generatedContentViewHelpText } from '../helpers';
import ContentViewIcon from '../components/ContentViewIcon';

export const HelpToolTip = ({ tooltip }) => (
  <span className="foreman-spaced-icon">
    <Tooltip
      position={TooltipPosition.top}
      content={tooltip}
    >
      <OutlinedQuestionCircleIcon />
    </Tooltip>
  </span>
);

export const LabelComposite = () => (
  <Flex>
    <FlexItem spacer={{ default: 'spacerNone' }}><ContentViewIcon composite /></FlexItem>
    <FlexItem>{__('Composite Content View')}</FlexItem>
  </Flex>
);

export const LabelComponent = () => (
  <Flex>
    <FlexItem spacer={{ default: 'spacerNone' }}><ContentViewIcon composite={false} /></FlexItem>
    <FlexItem>{__('Component Content View')}</FlexItem>
  </Flex>
);

export const LabelDependencies = () => (
  <Flex>
    <FlexItem spacer={{ default: 'spacerSm' }}>{__('Solve dependencies')}</FlexItem>
    <FlexItem>
      <HelpToolTip tooltip={dependenciesHelpText} />
    </FlexItem>
  </Flex>
);

export const LabelAutoPublish = () => (
  <Flex>
    <FlexItem spacer={{ default: 'spacerSm' }}>{__('Auto publish')}</FlexItem>
    <FlexItem>
      <HelpToolTip tooltip={autoPublishHelpText} />
    </FlexItem>
  </Flex>
);

export const LabelImportOnly = () => (
  <Flex>
    <FlexItem spacer={{ default: 'spacerSm' }}>{__('Import only')}</FlexItem>
    <FlexItem>
      <HelpToolTip tooltip={importOnlyHelpText} />
    </FlexItem>
  </Flex>
);

export const LabelGenerated = () => (
  <Flex>
    <FlexItem spacer={{ default: 'spacerSm' }}>{__('Generated')}</FlexItem>
    <FlexItem>
      <HelpToolTip tooltip={generatedContentViewHelpText} />
    </FlexItem>
  </Flex>
);

HelpToolTip.propTypes = {
  tooltip: PropTypes.string.isRequired,
};
