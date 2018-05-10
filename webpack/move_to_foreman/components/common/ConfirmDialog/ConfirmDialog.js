import React from 'react';
import PropTypes from 'prop-types';
import { Button } from 'patternfly-react';
import Dialog from '../Dialog';

const ConfirmDialog = (props) => {
  const {
    onCancel, cancelLabel, onConfirm, confirmLabel, confirmStyle, ...otherProps
  } = props;

  const buttons = [
    <Button
      key="cancel"
      bsStyle="default"
      className="btn-cancel"
      onClick={onCancel}
    >
      {cancelLabel}
    </Button>,
    <Button
      key="confirm"
      bsStyle={confirmStyle}
      onClick={onConfirm}
    >
      {confirmLabel}
    </Button>,
  ];

  return (
    <Dialog buttons={buttons} onCancel={onCancel} {...otherProps} />
  );
};

ConfirmDialog.propTypes = {
  ...Button.propTypes,
  onConfirm: PropTypes.func.isRequired,
  confirmLabel: PropTypes.string,
  confirmStyle: PropTypes.string,
};

ConfirmDialog.defaultProps = {
  ...Button.defaultProps,
  confirmLabel: __('Save'),
  cancelLabel: __('Cancel'),
  dangerouslySetInnerHTML: undefined,
  message: undefined,
  confirmStyle: 'primary',
};

export default ConfirmDialog;
