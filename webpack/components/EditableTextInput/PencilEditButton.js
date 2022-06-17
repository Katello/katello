import React from 'react';
import PropTypes from 'prop-types';
import {
  Button, Tooltip, TooltipPosition,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  PencilAltIcon,
} from '@patternfly/react-icons';

const PencilEditButton = ({ attribute, onEditClick }) => {

  return (
    <Tooltip
      position={TooltipPosition.top}
      content={__('Edit')}
    >
      <Button
        className="foreman-edit-icon"
        ouiaId={`edit-button-${attribute}`}
        aria-label={`edit ${attribute}`}
        variant="plain"
        onClick={onEditClick}
      >
        <PencilAltIcon />
      </Button>
    </Tooltip>
  );
};

export default PencilEditButton;

PencilEditButton.propTypes = {
  attribute: PropTypes.string.isRequired,
  onEditClick: PropTypes.func.isRequired,
};
