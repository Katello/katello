import React from 'react';
import PropTypes from 'prop-types';
import { Button, Tooltip, OverlayTrigger } from 'patternfly-react';
import './TooltipButton.scss';

const TooltipButton = ({
  disabled, title, tooltipText, tooltipId, tooltipPlacement, renderedButton, ...props
}) => {
  if (!disabled) return renderedButton || (<Button {...props} ouiaId="tooltip-button">{title}</Button>);
  return (
    <OverlayTrigger
      placement={tooltipPlacement}
      delayHide={150}
      overlay={<Tooltip id={tooltipId}>{tooltipText}</Tooltip>}
    >
      <div className="tooltip-button-helper">
        {renderedButton || (<Button {...props} disabled ouiaId="tooltip-disabled-button">{title}</Button>)}
      </div>
    </OverlayTrigger>
  );
};

TooltipButton.propTypes = {
  disabled: PropTypes.bool,
  title: PropTypes.string,
  tooltipText: PropTypes.string,
  tooltipId: PropTypes.string.isRequired,
  tooltipPlacement: PropTypes.string,
  renderedButton: PropTypes.node,
};

TooltipButton.defaultProps = {
  disabled: false,
  title: '',
  tooltipPlacement: 'bottom',
  tooltipText: '',
  renderedButton: null,
};

export default TooltipButton;
