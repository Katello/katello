import React from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';
import { noop } from 'foremanReact/common/helpers';
import { Icon } from '@theforeman/vendor/patternfly-react';

const CollapseSubscriptionGroupButton = ({
  collapsed, onClick, ...props
}) => {
  const iconName = collapsed ? 'angle-right' : 'angle-down';

  return (
    <Icon
      className="collapse-subscription-group-button"
      name={iconName}
      onClick={onClick}
      {...props}
    />
  );
};

CollapseSubscriptionGroupButton.propTypes = {
  collapsed: PropTypes.bool,
  onClick: PropTypes.func,
};

CollapseSubscriptionGroupButton.defaultProps = {
  collapsed: false,
  onClick: noop,
};

export default CollapseSubscriptionGroupButton;
