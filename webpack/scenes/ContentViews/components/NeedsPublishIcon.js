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
    content={composite ? __('Available updates in component content views.') :
      __('Audited updates on repositories and/or filters available.')}
  >
    <ArrowCircleUpIcon size="sm" style={{ color: '#0066CC', margin: '0 9px' }} />
  </Tooltip>
);

NeedsPublishIcon.propTypes = {
  composite: PropTypes.bool,
};

NeedsPublishIcon.defaultProps = {
  composite: false,
};

export default NeedsPublishIcon;
