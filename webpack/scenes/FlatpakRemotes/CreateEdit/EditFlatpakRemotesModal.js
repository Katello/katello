import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Modal, ModalVariant } from '@patternfly/react-core';
import FlatpakRemotesForm from './FlatpakRemoteform';

const EditFlatpakModal = ({ show, setIsOpen, remoteData }) => (
  <Modal
    ouiaId="edit-flatpak-modal"
    title={__('Edit Flatpak Remote')}
    variant={ModalVariant.medium}
    isOpen={show}
    onClose={() => { setIsOpen(false); }}
    appendTo={document.body}
  >
    <FlatpakRemotesForm setModalOpen={setIsOpen} remoteData={remoteData} />
  </Modal>
);

EditFlatpakModal.propTypes = {
  show: PropTypes.bool,
  setIsOpen: PropTypes.func,
  remoteData: PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
    url: PropTypes.string,
    username: PropTypes.string,
    password: PropTypes.string,
  }),
};

EditFlatpakModal.defaultProps = {
  show: false,
  setIsOpen: null,
  remoteData: null,
};

export default EditFlatpakModal;
