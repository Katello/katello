import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Modal,
  ModalVariant,
  Button,
  Icon,
  Title,
  Flex,
} from '@patternfly/react-core';
import { ExclamationTriangleIcon } from '@patternfly/react-icons';
import { addToast } from 'foremanReact/components/ToastsList/slice';
import { deleteHostCollection } from '../HostCollectionsActions';

const DeleteHostCollectionModal = ({ isOpen, onClose, hostCollection }) => {
  const dispatch = useDispatch();
  const [deleting, setDeleting] = useState(false);

  const handleSuccess = () => {
    setDeleting(false);
    dispatch(addToast({
      type: 'success',
      message: __('Host collection deleted successfully'),
    }));
    onClose();
    window.location.reload();
  };

  const handleError = (error) => {
    setDeleting(false);
    const errorMsg =
      error?.response?.data?.error?.full_messages?.[0] ||
      error?.response?.data?.displayMessage ||
      __('Failed to delete host collection');
    dispatch(addToast({
      type: 'error',
      message: errorMsg,
    }));
  };

  const handleDelete = () => {
    setDeleting(true);
    dispatch(deleteHostCollection(hostCollection.id, handleSuccess, handleError));
  };

  return (
    <Modal
      ouiaId="delete-host-collection-modal"
      variant={ModalVariant.small}
      title={[
        <Flex
          key="delete-modal-header"
          spaceItems={{ default: 'spaceItemsSm' }}
        >
          <Icon status="warning" key="exclamation-triangle">
            <ExclamationTriangleIcon />
          </Icon>
          <Title
            ouiaId="delete-host-collection-header"
            key="delete-title"
            headingLevel="h5"
            size="2xl"
          >
            {__('Delete host collection?')}
          </Title>
        </Flex>,
      ]}
      isOpen={isOpen}
      onClose={onClose}
      actions={[
        <Button
          ouiaId="delete-button"
          key="delete"
          variant="danger"
          onClick={handleDelete}
          isDisabled={deleting}
          isLoading={deleting}
        >
          {__('Delete')}
        </Button>,
        <Button
          ouiaId="cancel-button"
          key="cancel"
          variant="link"
          onClick={onClose}
          isDisabled={deleting}
        >
          {__('Cancel')}
        </Button>,
      ]}
    >
      {__('This host collection will be deleted and will no longer be available. This operation cannot be undone.')}
    </Modal>
  );
};

DeleteHostCollectionModal.propTypes = {
  isOpen: PropTypes.bool,
  onClose: PropTypes.func.isRequired,
  hostCollection: PropTypes.shape({
    id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
    name: PropTypes.string.isRequired,
  }).isRequired,
};

DeleteHostCollectionModal.defaultProps = {
  isOpen: false,
};

export default DeleteHostCollectionModal;
