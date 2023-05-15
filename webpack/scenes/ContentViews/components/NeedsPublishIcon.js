import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';
import { Tooltip } from '@patternfly/react-core';
import { ArrowCircleUpIcon } from '@patternfly/react-icons';
import './NeedsPublishIcon.scss';

const tooltipContent = (composite, determinate) => {
  let content = '';
  if (determinate) {
    content = composite ? __('Updates available: Component content view versions have been updated.') :
      __('Updates available: Repositories and/or filters have changed.');
  } else {
    content = __('We could not determine if publish is required for the content view. ' +
        'Audit records may have been cleaned or not created for this version.');
  }
  return content;
};

const NeedsPublishIcon = ({ composite, determinate }) => (
  <Tooltip
    position="auto"
    enableFlip
    entryDelay={400}
    content={tooltipContent(composite, determinate)}
  >
    <ArrowCircleUpIcon
      id={determinate ? 'determinate-needs-publish' : 'indeterminate-needs-publish'}
      size="sm"
      className={determinate ? 'determinate-needs-publish' : 'indeterminate-needs-publish'}
    />
  </Tooltip>
);

NeedsPublishIcon.propTypes = {
  composite: PropTypes.bool,
  determinate: PropTypes.bool,
};

NeedsPublishIcon.defaultProps = {
  composite: false,
  determinate: false,
};

export default NeedsPublishIcon;
