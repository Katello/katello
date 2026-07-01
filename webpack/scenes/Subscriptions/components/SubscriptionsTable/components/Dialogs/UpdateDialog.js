import React from 'react';
import PropTypes from 'prop-types';
import { sprintf, translate as __ } from 'foremanReact/common/I18n';
import { Modal, ModalVariant, Button } from '@patternfly/react-core';
import { buildPools } from '../../SubscriptionsTableHelpers';

const UpdateDialog = ({
  show,
  updatedQuantity,
  updateQuantity,
  showUpdateConfirm,
  enableEditing,
}) => {
  const quantityLength = Object.keys(updatedQuantity).length;
  const confirmEdit = async () => {
    showUpdateConfirm(false);
    if (quantityLength > 0) {
      await updateQuantity(buildPools(updatedQuantity));
    }
    enableEditing(false);
  };

  return (
    <Modal
      ouiaId="update-entitlements-modal"
      title={__('Editing Entitlements')}
      isOpen={show}
      variant={ModalVariant.small}
      onClose={() => showUpdateConfirm(false)}
      actions={[
        <Button
          ouiaId="update-entitlements-save-button"
          key="save"
          variant="primary"
          onClick={confirmEdit}
        >
          {__('Save')}
        </Button>,
        <Button
          ouiaId="update-entitlements-cancel-button"
          key="cancel"
          variant="link"
          onClick={() => showUpdateConfirm(false)}
        >
          {__('Cancel')}
        </Button>,
      ]}
    >
      <p>
        {sprintf(
          __("You're making changes to %s entitlement(s)"),
          quantityLength,
        )}
      </p>
    </Modal>
  );
};

UpdateDialog.propTypes = {
  show: PropTypes.bool.isRequired,
  updateQuantity: PropTypes.func.isRequired,
  updatedQuantity: PropTypes.shape({}).isRequired,
  showUpdateConfirm: PropTypes.func.isRequired,
  enableEditing: PropTypes.func.isRequired,
};

export default UpdateDialog;
