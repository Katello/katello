import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Modal, ModalVariant, Button } from '@patternfly/react-core';

const UnsavedChangesDialog = ({
  show, cancelEdit, showCancelConfirm,
}) => (
  <Modal
    ouiaId="unsaved-changes-modal"
    title={__('Editing Entitlements')}
    isOpen={show}
    variant={ModalVariant.small}
    onClose={() => showCancelConfirm(false)}
    actions={[
      <Button
        ouiaId="unsaved-changes-exit-button"
        key="exit"
        variant="primary"
        onClick={cancelEdit}
      >
        {__('Exit')}
      </Button>,
      <Button
        ouiaId="unsaved-changes-cancel-button"
        key="cancel"
        variant="link"
        onClick={() => showCancelConfirm(false)}
      >
        {__('Cancel')}
      </Button>,
    ]}
  >
    {__('You have unsaved changes. Do you want to exit without saving your changes?')}
  </Modal>
);

UnsavedChangesDialog.propTypes = {
  show: PropTypes.bool.isRequired,
  cancelEdit: PropTypes.func.isRequired,
  showCancelConfirm: PropTypes.func.isRequired,
};

export default UnsavedChangesDialog;
