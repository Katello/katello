import React from 'react';
import { useDispatch } from 'react-redux';
import { useHistory } from 'react-router-dom';
import PropTypes from 'prop-types';
import {
  Modal,
  ModalVariant,
  Button,
  Icon,
  Title,
  Flex,
} from '@patternfly/react-core';
import { ExclamationTriangleIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { deleteContentCredential } from '../ContentCredentialActions';

const DeleteContentCredentialModal = ({
  isModalOpen,
  handleModalToggle,
  credentialId,
  credentialName,
  refreshTable,
}) => {
  const dispatch = useDispatch();
  const history = useHistory();

  const handleDelete = () => {
    if (!credentialId) return;
    dispatch(deleteContentCredential(credentialId, () => {
      refreshTable();
      history.push('/labs/content_credentials');
    }));
    handleModalToggle();
  };

  return (
    <Modal
      ouiaId="content-credential-delete-modal"
      variant={ModalVariant.small}
      title={[
        <Flex key="delete-modal-header">
          <Icon status="warning" key="exclamation-triangle">
            <ExclamationTriangleIcon />
          </Icon>
          <Title
            ouiaId="content-credential-delete-header"
            key="delete-content-credential-title"
            headingLevel="h5"
            size="2xl"
          >
            {__('Delete content credential?')}
          </Title>
        </Flex>,
      ]}
      isOpen={isModalOpen}
      onClose={handleModalToggle}
      actions={[
        <Button
          ouiaId="delete-button"
          key="delete"
          variant="danger"
          isDisabled={!credentialId}
          onClick={handleDelete}
        >
          {__('Delete')}
        </Button>,
        <Button
          ouiaId="cancel-button"
          key="cancel"
          variant="link"
          onClick={handleModalToggle}
        >
          {__('Cancel')}
        </Button>,
      ]}
    >
      {credentialName &&
        __('Content credential %s will be deleted.').replace(
          '%s',
          credentialName,
        )}
    </Modal>
  );
};

DeleteContentCredentialModal.propTypes = {
  isModalOpen: PropTypes.bool,
  handleModalToggle: PropTypes.func,
  credentialId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  credentialName: PropTypes.string,
  refreshTable: PropTypes.func,
};

DeleteContentCredentialModal.defaultProps = {
  isModalOpen: false,
  handleModalToggle: () => {},
  credentialId: undefined,
  credentialName: undefined,
  refreshTable: () => {},
};

export default DeleteContentCredentialModal;
