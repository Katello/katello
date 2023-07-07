import React from 'react';
import {
  useDispatch,
} from 'react-redux';
import PropTypes from 'prop-types';
import { noop } from 'foremanReact/common/helpers';
import { Modal, ModalVariant, Button, Icon, Title, Flex } from '@patternfly/react-core';
import { ExclamationTriangleIcon } from '@patternfly/react-icons';
import { deleteActivationKey } from '../ActivationKeyActions';

const DeleteModal = ({ isModalOpen, handleModalToggle, akId }) => {
  const dispatch = useDispatch();

  const handleDelete = () => {
    dispatch(deleteActivationKey(akId));
    handleModalToggle();
    window.location.replace('/activation_keys');
  };

  return (
    <React.Fragment>
      <Modal
        ouiaId="ak-delete-modal"
        variant={ModalVariant.small}
        title={[
          <Flex>
            <Icon status="warning">
              <ExclamationTriangleIcon />
            </Icon>
            <Title ouiaId="ak-delete-header" headingLevel="h5" size="2xl">
              Delete activation key?
            </Title>
          </Flex>,
        ]}
        isOpen={isModalOpen}
        onClose={handleModalToggle}
        actions={[
          <Button ouiaId="delete-button" key="delete" variant="danger" onClick={handleDelete}>
            Delete
          </Button>,
          <Button ouiaId="cancel-button" key="cancel" variant="link" onClick={handleModalToggle}>
            Cancel
          </Button>,
        ]}
      >
        Activation Key will no longer be available for use. This operation cannot be undone.
      </Modal>
    </React.Fragment>
  );
};


DeleteModal.propTypes = {
  isModalOpen: PropTypes.bool,
  handleModalToggle: PropTypes.func,
  akId: PropTypes.string,
};

DeleteModal.defaultProps = {
  isModalOpen: false,
  handleModalToggle: noop,
  akId: '',
};

export default DeleteModal;
