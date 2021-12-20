import React from 'react';
import {
  TextListItem,
  TextListItemVariants,
  Tooltip,
  TooltipPosition,
  Spinner,
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
  loading,
  ...rest
}) => {
  const displayProps = {
    attribute, value, onEdit, disabled, currentAttribute, setCurrentAttribute, ...rest,
  };

  return (
    <React.Fragment key={label}>
      {label &&
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
      }
      <TextListItem component={TextListItemVariants.dd} className="foreman-spaced-list">
        {loading ?
          <Spinner
            key={label + currentAttribute}
            size="lg"
          /> :
          <>{boolean ?
            <EditableSwitch {...displayProps} /> :
            <EditableTextInput {...{
              ...displayProps, textArea,
            }}
            />}
          </>}
      </TextListItem>
    </React.Fragment>
  );
};

ActionableDetail.propTypes = {
  attribute: PropTypes.string.isRequired, // back-end name for API call
  label: PropTypes.string,
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
  loading: PropTypes.bool,
};

ActionableDetail.defaultProps = {
  label: undefined,
  textArea: false,
  boolean: false,
  tooltip: null,
  value: null,
  currentAttribute: undefined,
  setCurrentAttribute: undefined,
  disabled: false,
  loading: false,
};

export default ActionableDetail;
