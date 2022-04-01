import React from 'react';
import PropTypes from 'prop-types';
import { Modal, Button } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';

const ChangeHostCVModal = ({
  isOpen,
  closeModal,
  hostId,
  hostName,
}) => {
  const modalActions = ([
    <Button key="add" variant="primary" onClick={closeModal} isDisabled={false}>
      {__('Save')}
    </Button>,
    <Button key="cancel" variant="link" onClick={closeModal}>
      Cancel
    </Button>,
  ]);

  return (
    <Modal
      isOpen={isOpen}
      onClose={closeModal}
      title={__('Edit content view assignment')}
      width="50%"
      position="top"
      actions={modalActions}
      id="change-host-cv-modal"
    >{hostId} {hostName}
    </Modal>
  );
};

ChangeHostCVModal.propTypes = {
  isOpen: PropTypes.bool,
  closeModal: PropTypes.func,
  hostId: PropTypes.number.isRequired,
  hostName: PropTypes.string,
};

ChangeHostCVModal.defaultProps = {
  isOpen: false,
  closeModal: () => {},
  hostName: '',
};


export default ChangeHostCVModal;