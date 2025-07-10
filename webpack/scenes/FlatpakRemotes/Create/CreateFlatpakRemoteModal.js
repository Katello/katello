import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Modal, ModalVariant } from '@patternfly/react-core';
import CreateFlatpakForm from './CreateFlatpakRemoteform';

const CreateFlatpakModal = ({ show, setIsOpen }) => (
  <Modal
    ouiaId="create-Flatpak-modal"
    title={__('Create Flatpak')}
    variant={ModalVariant.small}
    isOpen={show}
    onClose={() => { setIsOpen(false); }}
    appendTo={document.body}
  >
    <CreateFlatpakForm setModalOpen={setIsOpen} />
  </Modal>
);

CreateFlatpakModal.propTypes = {
  show: PropTypes.bool,
  setIsOpen: PropTypes.func,
};

CreateFlatpakModal.defaultProps = {
  show: false,
  setIsOpen: null,
};

export default CreateFlatpakModal;
