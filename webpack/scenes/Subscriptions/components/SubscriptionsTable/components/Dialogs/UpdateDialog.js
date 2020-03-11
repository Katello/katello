import React from 'react';
import PropTypes from 'prop-types';
import { sprintf, translate as __ } from 'foremanReact/common/I18n';
import { MessageDialog } from 'patternfly-react';
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
    <MessageDialog
      show={show}
      title={__('Editing Entitlements')}
      secondaryContent={
        // eslint-disable-next-line react/no-danger
        <p dangerouslySetInnerHTML={{
          __html: sprintf(
            __("You're making changes to %(entitlementCount)s entitlement(s)"),
            {
              entitlementCount: `<b>${quantityLength}</b>`,
            },
          ),
        }}
        />
      }
      primaryActionButtonContent={__('Save')}
      primaryAction={confirmEdit}
      secondaryActionButtonContent={__('Cancel')}
      secondaryAction={() => showUpdateConfirm(false)}
      onHide={() => showUpdateConfirm(false)}
    />);
};

UpdateDialog.propTypes = {
  show: PropTypes.bool.isRequired,
  updateQuantity: PropTypes.func.isRequired,
  updatedQuantity: PropTypes.shape(PropTypes.Object).isRequired,
  showUpdateConfirm: PropTypes.func.isRequired,
  enableEditing: PropTypes.func.isRequired,
};

export default UpdateDialog;
