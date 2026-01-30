import React, { useContext } from 'react';
import { useForemanOrganization } from 'foremanReact/Root/Context/ForemanContext';
import { ForemanActionsBarContext } from 'foremanReact/components/HostDetails/ActionsBar';
import { useBulkModalOpen } from '../bulkModalState';
import BulkSystemPurposeModal from './BulkSystemPurposeModal';

const BulkSystemPurposeModalScene = () => {
  const orgId = useForemanOrganization()?.id;
  const { selectedCount, fetchBulkParams } = useContext(ForemanActionsBarContext);
  const { isOpen, close: closeModal } = useBulkModalOpen('bulk-system-purpose-modal');

  if (!orgId) return null;

  return (
    <BulkSystemPurposeModal
      key="bulk-system-purpose-modal"
      selectedCount={selectedCount}
      fetchBulkParams={fetchBulkParams}
      isOpen={isOpen}
      closeModal={closeModal}
      orgId={orgId}
    />
  );
};

export default BulkSystemPurposeModalScene;
