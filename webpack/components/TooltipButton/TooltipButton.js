import React, { useRef } from 'react';
import PropTypes from 'prop-types';
import { Button, Tooltip } from '@patternfly/react-core';
import './TooltipButton.scss';

const TooltipButton = ({
  disabled, title, tooltipText, tooltipId, tooltipPlacement, renderedButton, variant, ...props
}) => {
  const triggerRef = useRef(null);

  const effectiveVariant = disabled && variant === 'danger' ? 'secondary' : variant;

  if (!disabled) {
    return renderedButton || (
      <Button {...props} variant={variant} ouiaId={tooltipId}>
        {title}
      </Button>
    );
  }
  return (
    <>
      <div className="tooltip-button-helper" ref={triggerRef}>
        {renderedButton || (
          <Button {...props} variant={effectiveVariant} isDisabled ouiaId={tooltipId}>
            {title}
          </Button>
        )}
      </div>
      <Tooltip
        id={tooltipId}
        content={tooltipText}
        position={tooltipPlacement}
        exitDelay={150}
        triggerRef={triggerRef}
      />
    </>
  );
};

TooltipButton.propTypes = {
  disabled: PropTypes.bool,
  title: PropTypes.string,
  tooltipText: PropTypes.string,
  tooltipId: PropTypes.string.isRequired,
  tooltipPlacement: PropTypes.string,
  renderedButton: PropTypes.node,
  variant: PropTypes.string,
};

TooltipButton.defaultProps = {
  disabled: false,
  title: '',
  tooltipPlacement: 'bottom',
  tooltipText: '',
  renderedButton: null,
  variant: 'secondary',
};

export default TooltipButton;
