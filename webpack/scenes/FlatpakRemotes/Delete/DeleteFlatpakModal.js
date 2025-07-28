import React from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { Modal, ModalVariant, Button, Icon, Title, Flex } from '@patternfly/react-core';
import { ExclamationTriangleIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { deleteFlatpakRemote } from '../Details/FlatpakRemoteDetailActions';

const DeleteFlatpakModal = ({ isModalOpen, handleModalToggle, remoteId }) => {
  const dispatch = useDispatch();

  const handleDelete = () => {
    dispatch(deleteFlatpakRemote(remoteId, () => window.location.replace('/flatpak_remotes')));
    handleModalToggle();
  };

  return (
    <Modal
      ouiaId="flatpak-delete-modal"
      variant={ModalVariant.small}
      title={[
        <Flex key="delete-modal-header">
          <Icon status="warning" key="exclamation-triangle">
            <ExclamationTriangleIcon />
          </Icon>
          <Title ouiaId="flatpak-delete-header" key="delete-flatpak-title" headingLevel="h5" size="2xl">
            {__('Delete Flatpak remote?')}
          </Title>
        </Flex>,
      ]}
      isOpen={isModalOpen}
      onClose={handleModalToggle}
      actions={[
        <Button ouiaId="delete-button" key="delete" variant="danger" onClick={handleDelete}>
          {__('Delete')}
        </Button>,
        <Button ouiaId="cancel-button" key="cancel" variant="link" onClick={handleModalToggle}>
          {__('Cancel')}
        </Button>,
      ]}
    >
      {__('This Flatpak remote will be deleted. Repositories mirrored from this remote will remain available and functional for use')}
    </Modal>
  );
};

DeleteFlatpakModal.propTypes = {
  isModalOpen: PropTypes.bool,
  handleModalToggle: PropTypes.func,
  remoteId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
};

DeleteFlatpakModal.defaultProps = {
  isModalOpen: false,
  handleModalToggle: () => {},
  remoteId: undefined,
};

export default DeleteFlatpakModal;
