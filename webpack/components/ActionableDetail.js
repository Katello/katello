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
  attribute, label, value, textArea, boolean, tooltip, onEdit,
}) => {
  const displayProps = { attribute, value, onEdit };

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
          <EditableTextInput {...{ ...displayProps, textArea, onEdit }} />}
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
};

ActionableDetail.defaultProps = {
  textArea: false,
  boolean: false,
  tooltip: null,
  value: null,
};

export default ActionableDetail;
