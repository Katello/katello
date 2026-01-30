import React, { useContext } from 'react';
import { useForemanOrganization } from 'foremanReact/Root/Context/ForemanContext';
import { ForemanActionsBarContext } from 'foremanReact/components/HostDetails/ActionsBar';
import { useBulkModalOpen } from '../bulkModalState';
import BulkManageTracesModal from './BulkManageTracesModal';

const BulkManageTracesModalScene = () => {
  const orgId = useForemanOrganization()?.id;
  const contextValue = useContext(ForemanActionsBarContext);
  const { selectedCount, fetchBulkParams } = contextValue || {};
  const { isOpen, close: closeModal } = useBulkModalOpen('bulk-manage-traces-modal');

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
      isOpen={isOpen}
      closeModal={closeModal}
      orgId={orgId}
    />
  );
};

export default BulkManageTracesModalScene;
