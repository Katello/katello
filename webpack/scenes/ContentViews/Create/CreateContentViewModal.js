import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Modal, ModalVariant } from '@patternfly/react-core';
import CreateContentViewForm from './CreateContentViewForm';

const CreateContentViewModal = ({ show, setIsOpen }) => (
  <Modal
    ouiaId="create-content-view-modal"
    title={__('Create content view')}
    variant={ModalVariant.small}
    isOpen={show}
    onClose={() => { setIsOpen(false); }}
    appendTo={document.body}
  >
    <CreateContentViewForm setModalOpen={setIsOpen} />
  </Modal>
);

CreateContentViewModal.propTypes = {
  show: PropTypes.bool,
  setIsOpen: PropTypes.func,
};

CreateContentViewModal.defaultProps = {
  show: false,
  setIsOpen: null,
};

export default CreateContentViewModal;
