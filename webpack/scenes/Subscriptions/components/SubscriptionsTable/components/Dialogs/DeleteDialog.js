import React from 'react';
import PropTypes from 'prop-types';
import { Modal, ModalVariant, Button } from '@patternfly/react-core';
import { sprintf, translate as __ } from 'foremanReact/common/I18n';

const DeleteDialog = ({
  show, selectedRows, onDeleteSubscriptions, onSubscriptionDeleteModalClose,
}) => (
  <Modal
    ouiaId="delete-subscriptions-modal"
    title={__('Confirm Deletion')}
    isOpen={show}
    variant={ModalVariant.small}
    onClose={onSubscriptionDeleteModalClose}
    actions={[
      <Button
        ouiaId="delete-subscriptions-confirm-button"
        key="delete"
        variant="danger"
        onClick={() => onDeleteSubscriptions(selectedRows)}
      >
        {__('Delete')}
      </Button>,
      <Button
        ouiaId="delete-subscriptions-cancel-button"
        key="cancel"
        variant="link"
        onClick={onSubscriptionDeleteModalClose}
      >
        {__('Cancel')}
      </Button>,
    ]}
  >
    <p>
      {sprintf(
        __('Are you sure you want to delete %s subscription(s)? This action will remove the subscription(s) and refresh your manifest. All systems using these subscription(s) will lose them and also may lose access to updates and Errata.'),
        selectedRows.length,
      )}
    </p>
  </Modal>
);

DeleteDialog.propTypes = {
  show: PropTypes.bool.isRequired,
  selectedRows: PropTypes.arrayOf(PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.number,
  ])).isRequired,
  onDeleteSubscriptions: PropTypes.func.isRequired,
  onSubscriptionDeleteModalClose: PropTypes.func.isRequired,
};

export default DeleteDialog;
