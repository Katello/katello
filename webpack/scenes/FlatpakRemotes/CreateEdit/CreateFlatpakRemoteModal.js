import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Modal, ModalVariant } from '@patternfly/react-core';
import FlatpakRemotesForm from './FlatpakRemoteform';

const CreateFlatpakModal = ({ show, setIsOpen }) => (
  <Modal
    ouiaId="create-flatpak-modal"
    title={__('Create Flatpak Remote')}
    variant={ModalVariant.small}
    isOpen={show}
    onClose={() => { setIsOpen(false); }}
    appendTo={document.body}
  >
    <FlatpakRemotesForm setModalOpen={setIsOpen} />
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
