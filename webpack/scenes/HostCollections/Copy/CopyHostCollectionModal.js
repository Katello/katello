import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Modal,
  ModalVariant,
  Form,
  FormGroup,
  TextInput,
  ActionGroup,
  Button,
} from '@patternfly/react-core';
import { addToast } from 'foremanReact/components/ToastsList/slice';
import { copyHostCollection } from '../HostCollectionsActions';

const CopyHostCollectionModal = ({ isOpen, onClose, hostCollection }) => {
  const dispatch = useDispatch();
  const [newName, setNewName] = useState(`Copy of ${hostCollection?.name || ''}`);
  const [copying, setCopying] = useState(false);

  const handleSuccess = (data) => {
    setCopying(false);
    dispatch(addToast({
      type: 'success',
      message: __('Host collection copied successfully'),
    }));
    onClose();
    window.location.href = `/labs/host_collections/${data.id}`;
  };

  const handleError = (error) => {
    setCopying(false);
    const errorMsg =
      error?.response?.data?.error?.full_messages?.[0] ||
      error?.response?.data?.displayMessage ||
      __('Failed to copy host collection');
    dispatch(addToast({
      type: 'error',
      message: errorMsg,
    }));
  };

  const onCopy = () => {
    setCopying(true);
    dispatch(copyHostCollection(hostCollection.id, newName, handleSuccess, handleError));
  };

  const submitDisabled = !newName?.trim().length || copying;

  return (
    <Modal
      ouiaId="copy-host-collection-modal"
      title={__('Copy host collection')}
      variant={ModalVariant.small}
      isOpen={isOpen}
      onClose={onClose}
      appendTo={document.body}
    >
      <Form
        onSubmit={(e) => {
          e.preventDefault();
          onCopy();
        }}
      >
        <FormGroup label={__('Name')} isRequired fieldId="new-name">
          <TextInput
            isRequired
            type="text"
            id="new-name"
            aria-label="new-name"
            ouiaId="new-name-input"
            name="new-name"
            value={newName}
            onChange={(_event, value) => setNewName(value)}
            isDisabled={copying}
          />
        </FormGroup>
        <ActionGroup>
          <Button
            ouiaId="copy-button"
            aria-label="copy"
            variant="primary"
            isDisabled={submitDisabled}
            isLoading={copying}
            type="submit"
          >
            {__('Copy')}
          </Button>
          <Button
            ouiaId="cancel-button"
            variant="link"
            onClick={onClose}
            isDisabled={copying}
          >
            {__('Cancel')}
          </Button>
        </ActionGroup>
      </Form>
    </Modal>
  );
};

CopyHostCollectionModal.propTypes = {
  isOpen: PropTypes.bool,
  onClose: PropTypes.func.isRequired,
  hostCollection: PropTypes.shape({
    id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
    name: PropTypes.string.isRequired,
  }).isRequired,
};

CopyHostCollectionModal.defaultProps = {
  isOpen: false,
};

export default CopyHostCollectionModal;
