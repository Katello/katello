import React, { useContext } from 'react';
import { useForemanOrganization } from 'foremanReact/Root/Context/ForemanContext';
import { ForemanActionsBarContext } from 'foremanReact/components/HostDetails/ActionsBar';
import { useForemanModal } from 'foremanReact/components/ForemanModal/ForemanModalHooks';
import BulkManageTracesModal from './BulkManageTracesModal';

const BulkManageTracesModalScene = () => {
  const orgId = useForemanOrganization()?.id;
  const contextValue = useContext(ForemanActionsBarContext);
  const { selectedCount, fetchBulkParams } = contextValue || {};
  const { modalOpen, setModalClosed } = useForemanModal({ id: 'bulk-manage-traces-modal' });

  if (!orgId) return null;

  // Don't render if we don't have the required context
  if (!fetchBulkParams) {
    return null;
  }

  return (
    <BulkManageTracesModal
      key="bulk-manage-traces-modal"
      selectedCount={selectedCount || 0}
      fetchBulkParams={fetchBulkParams}
      isOpen={modalOpen}
      closeModal={setModalClosed}
      orgId={orgId}
    />
  );
};

export default BulkManageTracesModalScene;
