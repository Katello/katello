import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Modal, ModalVariant } from '@patternfly/react-core';
import FlatpakRemotesForm from './FlatpakRemoteform';

const CreateFlatpakModal = ({ show, setIsOpen, hasRedhatRemote }) => (
  <Modal
    ouiaId="create-flatpak-modal"
    title={__('Create Flatpak remote')}
    variant={ModalVariant.medium}
    isOpen={show}
    onClose={() => { setIsOpen(false); }}
    appendTo={document.body}
  >
    <FlatpakRemotesForm setModalOpen={setIsOpen} hasRedhatRemote={hasRedhatRemote} />
  </Modal>
);

CreateFlatpakModal.propTypes = {
  show: PropTypes.bool,
  setIsOpen: PropTypes.func,
  hasRedhatRemote: PropTypes.bool,
};

CreateFlatpakModal.defaultProps = {
  show: false,
  setIsOpen: null,
  hasRedhatRemote: true,
};

export default CreateFlatpakModal;
