import React from 'react';
import { Modal, Button } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';

const PackageInstallModal = ({ isOpen, toggleModal, hostId }) => {
  const modalActions = ([
    <Button key="confirm" variant="primary" onClick={() => console.log('install')}>
      Install
    </Button>,
    <Button key="cancel" variant="link" onClick={toggleModal}>
      Cancel
    </Button>,
  ]);

  return (
    <Modal
      isOpen={isOpen}
      onClose={toggleModal}
      title={__('Install packages')}
      width="50%"
      actions={modalActions}
    >
      hi {hostId}
    </Modal>
  );
};

PackageInstallModal.propTypes = {
  isOpen: PropTypes.bool.isRequired,
  toggleModal: PropTypes.func.isRequired,
  hostId: PropTypes.number.isRequired,
};

export default PackageInstallModal;
