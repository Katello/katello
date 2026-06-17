import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Modal, ModalVariant, Button } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import CreateContentCredentialForm from './CreateContentCredentialForm';

const CreateContentCredentialModal = ({ show, setIsOpen, refreshTable }) => {
  const [formState, setFormState] = useState({});

  const handleSave = () => {
    if (formState.onSave) {
      formState.onSave();
    }
  };

  const handleClose = () => {
    setIsOpen(false);
  };

  return (
    <Modal
      ouiaId="create-content-credential-modal"
      title={__('Create content credential')}
      variant={ModalVariant.medium}
      isOpen={show}
      onClose={handleClose}
      appendTo={document.body}
      actions={[
        <Button
          key="create"
          ouiaId="create-content-credential-create-button"
          variant="primary"
          onClick={handleSave}
          isDisabled={formState.submitDisabled}
          isLoading={formState.saving}
        >
          {__('Create')}
        </Button>,
        <Button
          key="cancel"
          ouiaId="create-content-credential-cancel-button"
          variant="link"
          onClick={handleClose}
        >
          {__('Cancel')}
        </Button>,
      ]}
    >
      <CreateContentCredentialForm
        setModalOpen={setIsOpen}
        setFormState={setFormState}
        refreshTable={refreshTable}
      />
    </Modal>
  );
};

CreateContentCredentialModal.propTypes = {
  show: PropTypes.bool,
  setIsOpen: PropTypes.func.isRequired,
  refreshTable: PropTypes.func,
};

CreateContentCredentialModal.defaultProps = {
  show: false,
  refreshTable: () => {},
};

export default CreateContentCredentialModal;
