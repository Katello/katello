import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Modal, ModalVariant } from '@patternfly/react-core';
import CreateHostCollectionForm from './CreateHostCollectionForm';

const CreateHostCollectionModal = ({ isOpen, onClose }) => (
  <Modal
    ouiaId="create-host-collection-modal"
    title={__('Create host collection')}
    variant={ModalVariant.small}
    isOpen={isOpen}
    onClose={onClose}
    appendTo={document.body}
  >
    <CreateHostCollectionForm onClose={onClose} />
  </Modal>
);

CreateHostCollectionModal.propTypes = {
  isOpen: PropTypes.bool,
  onClose: PropTypes.func.isRequired,
};

CreateHostCollectionModal.defaultProps = {
  isOpen: false,
};

export default CreateHostCollectionModal;
