import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Modal, ModalVariant, Button } from '@patternfly/react-core';

const InputsErrorsDialog = ({
  show, showErrorDialog,
}) => (
  <Modal
    ouiaId="inputs-errors-modal"
    title={__('Editing Entitlements')}
    isOpen={show}
    variant={ModalVariant.small}
    onClose={() => showErrorDialog(false)}
    actions={[
      <Button
        ouiaId="inputs-errors-ok-button"
        key="ok"
        variant="primary"
        onClick={() => showErrorDialog(false)}
      >
        {__('Ok')}
      </Button>,
    ]}
  >
    {__('Some of your inputs contain errors. Please update them and save your changes again.')}
  </Modal>
);

InputsErrorsDialog.propTypes = {
  show: PropTypes.bool.isRequired,
  showErrorDialog: PropTypes.func.isRequired,
};

export default InputsErrorsDialog;
