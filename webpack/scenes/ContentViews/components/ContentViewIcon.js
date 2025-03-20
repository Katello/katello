import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';
import { Tooltip, Icon } from '@patternfly/react-core';
import { EnterpriseIcon, RegistryIcon, SyncAltIcon } from '@patternfly/react-icons';
import './contentViewIcon.scss';

const ContentViewIcon = ({
  composite, rolling, count, description, style, ...toolTipProps
}) => {
  const props = {
    className: 'svg-icon-component',
  };
  let content = __('Content view');
  let icon = <Icon size="sm"><EnterpriseIcon {...props} /></Icon>;
  if (composite) {
    props.className = 'svg-icon-composite';
    content = __('Composite content view');
    icon = <Icon size="md"><RegistryIcon {...props} /></Icon>;
  } else if (rolling) {
    props.className = 'svg-icon-rolling';
    content = __('Rolling content view');
    icon = <Icon size="sm"><SyncAltIcon {...props} /></Icon>;
  }

  const cvIcon = (
    <Tooltip
      position="auto"
      enableFlip
      entryDelay={400}
      content={content}
      {...toolTipProps}
    >
      {icon}
    </Tooltip>
  );
  return (
    <div aria-label="content_view_icon" className="svg-centered-container" style={style}>
      {count && <span className="composite-component-count">{count}</span>}
      {cvIcon}
      <span>{description}</span>
    </div>
  );
};

ContentViewIcon.propTypes = {
  composite: PropTypes.bool,
  rolling: PropTypes.bool,
  count: PropTypes.node,
  description: PropTypes.node,
  style: PropTypes.shape({}),
};

ContentViewIcon.defaultProps = {
  composite: false,
  rolling: false,
  count: null,
  description: null,
  style: {},
};

export default ContentViewIcon;
