import React, { useContext } from 'react';
import { useForemanOrganization } from 'foremanReact/Root/Context/ForemanContext';
import { ForemanActionsBarContext } from 'foremanReact/components/HostDetails/ActionsBar';
import { useBulkModalOpen } from 'foremanReact/common/BulkModalStateHelper';
import BulkAssignCVEnvsModal from './BulkAssignCVEnvsModal';

const BulkAssignCVEnvsModalScene = () => {
  const orgId = useForemanOrganization()?.id;
  const { selectedCount, fetchBulkParams, refreshTableData } = useContext(ForemanActionsBarContext);
  const { isOpen, close: closeModal } = useBulkModalOpen('bulk-assign-cves-modal');

  if (!orgId) return null;

  return (
    <BulkAssignCVEnvsModal
      key="bulk-assign-cves-modal"
      selectedCount={selectedCount}
      fetchBulkParams={fetchBulkParams}
      isOpen={isOpen}
      closeModal={closeModal}
      orgId={orgId}
      refreshTableData={refreshTableData}
    />
  );
};

export default BulkAssignCVEnvsModalScene;
