import React, { useRef } from 'react';
import PropTypes from 'prop-types';
import { Button } from 'patternfly-react';
import { Tooltip } from '@patternfly/react-core';
import './TooltipButton.scss';

const TooltipButton = ({
  disabled, title, tooltipText, tooltipId, tooltipPlacement, renderedButton, ...props
}) => {
  const triggerRef = useRef(null);

  if (!disabled) return renderedButton || (<Button {...props}>{title}</Button>);
  return (
    <>
      <div className="tooltip-button-helper" ref={triggerRef}>
        {renderedButton || (<Button {...props} disabled>{title}</Button>)}
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
};

TooltipButton.defaultProps = {
  disabled: false,
  title: '',
  tooltipPlacement: 'bottom',
  tooltipText: '',
  renderedButton: null,
};

export default TooltipButton;
