import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import { translate as __ } from 'foremanReact/common/I18n';
import { Switch, Popover, Button } from '@patternfly/react-core';
import { StarIcon, InfoCircleIcon } from '@patternfly/react-icons';

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
        id="recommended-repos-switch"
        aria-label={__('Recommended repositories toggle')}
        ouiaId="recommended-repos-switch"
        isChecked={enabled}
        onChange={(_event, checked) => onChange(checked)}
      />
      <StarIcon />
      {children}
      <Popover bodyContent={help}>
        <Button
          variant="plain"
          aria-label={__('Help')}
          ouiaId="recommended-repos-help-button"
          className="recommended-repos-help-button"
        >
          <InfoCircleIcon />
        </Button>
      </Popover>
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
