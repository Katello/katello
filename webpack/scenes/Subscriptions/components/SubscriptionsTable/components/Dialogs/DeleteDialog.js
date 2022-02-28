import React from 'react';
import PropTypes from 'prop-types';
import { MessageDialog } from 'patternfly-react';
import { sprintf, translate as __ } from 'foremanReact/common/I18n';

const DeleteDialog = ({
  show, selectedRows, onDeleteSubscriptions, onSubscriptionDeleteModalClose,
}) => (
  <MessageDialog
    show={show}
    title={__('Confirm Deletion')}
    secondaryContent={
      // eslint-disable-next-line react/no-danger
      <p dangerouslySetInnerHTML={{
        __html: sprintf(
          __(`Are you sure you want to delete %(entitlementCount)s
                  subscription(s)? This action will remove the subscription(s) and
                  refresh your manifest. All systems using these subscription(s) will
                  lose them and also may lose access to updates and Errata.`),
          {
            entitlementCount: `<b>${selectedRows.length}</b>`,
          },
        ),
      }}
      />
    }
    primaryActionButtonContent={__('Delete')}
    primaryAction={() => onDeleteSubscriptions(selectedRows)}
    primaryActionButtonBsStyle="danger"
    secondaryActionButtonContent={__('Cancel')}
    secondaryAction={onSubscriptionDeleteModalClose}
    onHide={onSubscriptionDeleteModalClose}
    accessibleName="deleteConfirmationDialog"
    accessibleDescription="deleteConfirmationDialogContent"
  />);

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
