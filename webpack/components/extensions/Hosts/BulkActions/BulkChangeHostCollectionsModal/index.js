import React, { useContext } from 'react';
import PropTypes from 'prop-types';
import { MenuItem } from '@patternfly/react-core';
import { BanIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { useForemanOrganization } from 'foremanReact/Root/Context/ForemanContext';
import { ForemanActionsBarContext } from 'foremanReact/components/HostDetails/ActionsBar';
import { useForemanModal } from 'foremanReact/components/ForemanModal/ForemanModalHooks';
import BulkChangeHostCollectionsModal from './BulkChangeHostCollectionsModal';

const DisabledMenuItemDescription = ({ disabledReason }) => (
  <span className="disabled-menu-item-span">
    <span className="disabled-menu-item-icon">
      <BanIcon />
    </span>
    <p className="disabled-menu-item-p">
      {disabledReason}
    </p>
  </span>
);

DisabledMenuItemDescription.propTypes = {
  disabledReason: PropTypes.string.isRequired,
};

// This component renders only the MenuItem trigger (for the slot in the menu)
export const BulkChangeHostCollectionsMenuItem = ({ selectedCount }) => {
  const orgId = useForemanOrganization()?.id;
  const { setModalOpen } = useForemanModal({ id: 'bulk-change-host-collections-modal' });

  return (
    <MenuItem
      itemId="change-host-collections-dropdown-item"
      key="change-host-collections-dropdown-item"
      onClick={setModalOpen}
      isDisabled={selectedCount === 0 || !orgId}
      description={!orgId && <DisabledMenuItemDescription disabledReason={__('To manage host collections, a specific organization must be selected from the organization context.')} />}
    >
      {__('Host collections')}
    </MenuItem>
  );
};

BulkChangeHostCollectionsMenuItem.propTypes = {
  selectedCount: PropTypes.number,
};

BulkChangeHostCollectionsMenuItem.defaultProps = {
  selectedCount: 0,
};

// This component renders only the modal (for the _all-hosts-modals slot)
const BulkChangeHostCollectionsModalScene = () => {
  const orgId = useForemanOrganization()?.id;
  const { selectedCount, fetchBulkParams } = useContext(ForemanActionsBarContext);
  const { modalOpen, setModalClosed } = useForemanModal({ id: 'bulk-change-host-collections-modal' });

  if (!orgId) return null;

  return (
    <BulkChangeHostCollectionsModal
      key="bulk-change-host-collections-modal"
      fetchBulkParams={fetchBulkParams}
      selectedCount={selectedCount}
      isOpen={modalOpen}
      closeModal={setModalClosed}
    />
  );
};

export default BulkChangeHostCollectionsModalScene;
