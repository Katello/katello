import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Modal, ModalVariant } from '@patternfly/react-core';
import FlatpakRemotesForm from './FlatpakRemoteform';

const EditFlatpakModal = ({ show, setIsOpen }) => (
  <Modal
    ouiaId="edit-flatpak-modal"
    title={__('Edit Flatpak Remote')}
    variant={ModalVariant.small}
    isOpen={show}
    onClose={() => { setIsOpen(false); }}
    appendTo={document.body}
  >
    <FlatpakRemotesForm setModalOpen={setIsOpen} />
  </Modal>
);

EditFlatpakModal.propTypes = {
  show: PropTypes.bool,
  setIsOpen: PropTypes.func,
};

EditFlatpakModal.defaultProps = {
  show: false,
  setIsOpen: null,
};

export default EditFlatpakModal;
