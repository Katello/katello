import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';
import { Tooltip } from '@patternfly/react-core';
import { ArrowCircleUpIcon } from '@patternfly/react-icons';

const NeedsPublishIcon = ({ composite }) => (
  <Tooltip
    position="auto"
    enableFlip
    entryDelay={400}
    content={composite ? __('Updates available: Component content view versions have been updated.') :
      __('Updates available: Repositories and/or filters have changed.')}
  >
    <ArrowCircleUpIcon size="sm" style={{ color: 'var(--pf-global--primary-color--100)', margin: '0 9px' }} />
  </Tooltip>
);

NeedsPublishIcon.propTypes = {
  composite: PropTypes.bool,
};

NeedsPublishIcon.defaultProps = {
  composite: false,
};

export default NeedsPublishIcon;
