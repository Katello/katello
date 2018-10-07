import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Button, Modal, Icon } from 'patternfly-react';

const Dialog = (props) => {
  const buttons = (props.buttons)
    ? props.buttons
    : (
      <Button
        key="cancel"
        bsStyle="default"
        className="btn-cancel"
        onClick={props.onCancel}
      >
        {props.cancelLabel}
      </Button>
    );
  return (
    <Modal show={props.show}>
      <Modal.Header>
        <Button
          className="close"
          onClick={props.onCancel}
          aria-hidden="true"
          aria-label={props.cancelLabel}
        >
          <Icon type="pf" name="close" />
        </Button>
        <Modal.Title>{props.title}</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        {/* eslint-disable react/no-danger */}
        <p dangerouslySetInnerHTML={props.dangerouslySetInnerHTML}>
          {props.message}
        </p>
        {/* eslint-enable react/no-danger */}
      </Modal.Body>
      <Modal.Footer>
        {buttons}
      </Modal.Footer>
    </Modal>
  );
};

Dialog.propTypes = {
  show: PropTypes.bool.isRequired,
  onCancel: PropTypes.func.isRequired,
  message: PropTypes.string,
  title: PropTypes.string.isRequired,
  cancelLabel: PropTypes.string,
  dangerouslySetInnerHTML: PropTypes.shape({}),
  buttons: PropTypes.oneOfType([
    PropTypes.arrayOf(PropTypes.node),
    PropTypes.node,
  ]),
};

Dialog.defaultProps = {
  cancelLabel: __('Ok'),
  dangerouslySetInnerHTML: undefined,
  message: undefined,
  buttons: undefined,
};

export default Dialog;
