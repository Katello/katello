import React, { useContext } from 'react';
import { useForemanOrganization, useForemanContext } from 'foremanReact/Root/Context/ForemanContext';
import { ForemanActionsBarContext } from 'foremanReact/components/HostDetails/ActionsBar';
import { useBulkModalOpen } from '../bulkModalState';
import BulkAssignCVEnvsModal from './BulkAssignCVEnvsModal';

const BulkAssignCVEnvsModalScene = () => {
  const orgId = useForemanOrganization()?.id;
  const { selectedCount, fetchBulkParams } = useContext(ForemanActionsBarContext);
  const { isOpen, close: closeModal } = useBulkModalOpen('bulk-assign-cves-modal');
  const foremanContext = useForemanContext();
  const allowMultipleContentViews =
      foremanContext?.metadata?.katello?.allow_multiple_content_views ?? true;


  if (!orgId) return null;

  return (
    <BulkAssignCVEnvsModal
      key="bulk-assign-cves-modal"
      selectedCount={selectedCount}
      fetchBulkParams={fetchBulkParams}
      isOpen={isOpen}
      closeModal={closeModal}
      orgId={orgId}
      allowMultipleContentViews={allowMultipleContentViews}
    />
  );
};

export default BulkAssignCVEnvsModalScene;
