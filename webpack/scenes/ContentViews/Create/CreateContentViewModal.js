import React from 'react';
import PropTypes from 'prop-types';
import { Modal, ModalVariant } from '@patternfly/react-core';
import CreateContentViewForm from './CreateContentViewForm';

const CreateContentViewModal = ({ show, setIsOpen }) => (
  <Modal
    title="Create content view"
    variant={ModalVariant.large}
    isOpen={show}
    width="50%"
    onClose={() => { setIsOpen(false); }}
    appendTo={document.body}
  ><CreateContentViewForm setModalOpen={setIsOpen} />
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
