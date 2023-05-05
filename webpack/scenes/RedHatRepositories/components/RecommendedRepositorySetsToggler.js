import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import { translate as __ } from 'foremanReact/common/I18n';
import { Switch, Icon, FieldLevelHelp } from 'patternfly-react';

import './RecommendedRepositorySetsToggler.scss';

const RecommendedRepositorySetsToggler = ({
  enabled,
  className,
  children,
  help,
  onChange,
  ...props
}) => {
  const classes = classNames('recommended-repositories-toggler-container', className);

  return (
    <div className={classes} {...props}>
      <Switch
        ouiaId="enabled-repo-set-switch"
        bsSize="mini"
        value={enabled}
        onChange={() => onChange(!enabled)}
      />
      <Icon type="fa" name="star" />
      {children}
      <FieldLevelHelp content={help} />
    </div>
  );
};

RecommendedRepositorySetsToggler.propTypes = {
  enabled: PropTypes.bool,
  className: PropTypes.string,
  children: PropTypes.node,
  help: PropTypes.node,
  onChange: PropTypes.func,
};

RecommendedRepositorySetsToggler.defaultProps = {
  enabled: false,
  className: '',
  children: __('Recommended Repositories'),
  help: __('This shows repositories that are used in a typical setup.'),
  onChange: () => null,
};

export default RecommendedRepositorySetsToggler;
