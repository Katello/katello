import React from 'react';
import {
  TextListItem,
  TextListItemVariants,
  Tooltip,
  TooltipPosition,
} from '@patternfly/react-core';
import { OutlinedQuestionCircleIcon } from '@patternfly/react-icons';
import PropTypes from 'prop-types';

import EditableTextInput from './EditableTextInput';
import EditableSwitch from './EditableSwitch';

// To be used within a TextList
const ActionableDetail = ({
  attribute,
  label,
  value,
  textArea,
  boolean,
  tooltip,
  onEdit,
  currentAttribute,
  setCurrentAttribute,
  disabled,
}) => {
  const displayProps = {
    attribute, value, onEdit, disabled,
  };

  return (
    <React.Fragment key={label}>
      <TextListItem component={TextListItemVariants.dt}>
        {label}
        {tooltip &&
          <span className="foreman-spaced-icon">
            <Tooltip
              position={TooltipPosition.top}
              content={tooltip}
            >
              <OutlinedQuestionCircleIcon />
            </Tooltip>
          </span>
        }
      </TextListItem>
      <TextListItem component={TextListItemVariants.dd} className="foreman-spaced-list">
        {boolean ?
          <EditableSwitch {...displayProps} /> :
          <EditableTextInput {...{
            ...displayProps, textArea, onEdit, currentAttribute, setCurrentAttribute,
          }}
          />}
      </TextListItem>
    </React.Fragment>
  );
};

ActionableDetail.propTypes = {
  attribute: PropTypes.string.isRequired, // back-end name for API call
  label: PropTypes.string.isRequired, // displayed label
  value: PropTypes.oneOfType([ // displayed value
    PropTypes.string,
    PropTypes.bool,
  ]),
  onEdit: PropTypes.func.isRequired,
  textArea: PropTypes.bool,
  boolean: PropTypes.bool,
  tooltip: PropTypes.string,
  currentAttribute: PropTypes.string,
  setCurrentAttribute: PropTypes.func,
  disabled: PropTypes.bool,
};

ActionableDetail.defaultProps = {
  textArea: false,
  boolean: false,
  tooltip: null,
  value: null,
  currentAttribute: undefined,
  setCurrentAttribute: undefined,
  disabled: false,
};

export default ActionableDetail;
