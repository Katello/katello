import React from 'react';
import PropTypes from 'prop-types';
import { Modal, ModalVariant } from '@patternfly/react-core';
import CopyContentViewForm from './CopyContentViewForm';

const CopyContentViewModal = ({
  cvId, cvName, show, setIsOpen,
}) => (
  <Modal
    title={`Copy content view ${cvName}`}
    variant={ModalVariant.large}
    isOpen={show}
    width="50%"
    onClose={() => { setIsOpen(false); }}
    appendTo={document.body}
  ><CopyContentViewForm cvId={cvId} setModalOpen={setIsOpen} />
  </Modal>
);

CopyContentViewModal.propTypes = {
  cvId: PropTypes.string,
  cvName: PropTypes.string,
  show: PropTypes.bool,
  setIsOpen: PropTypes.func,
};

CopyContentViewModal.defaultProps = {
  cvId: null,
  cvName: null,
  show: false,
  setIsOpen: null,
};

export default CopyContentViewModal;
