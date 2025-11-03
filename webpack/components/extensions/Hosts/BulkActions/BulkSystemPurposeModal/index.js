import React, { useContext } from 'react';
import { useForemanOrganization } from 'foremanReact/Root/Context/ForemanContext';
import { ForemanActionsBarContext } from 'foremanReact/components/HostDetails/ActionsBar';
import { useForemanModal } from 'foremanReact/components/ForemanModal/ForemanModalHooks';
import BulkSystemPurposeModal from './BulkSystemPurposeModal';

const BulkSystemPurposeModalScene = () => {
  const orgId = useForemanOrganization()?.id;
  const { selectedCount, fetchBulkParams } = useContext(ForemanActionsBarContext);
  const { modalOpen, setModalClosed } = useForemanModal({ id: 'bulk-system-purpose-modal' });

  if (!orgId) return null;

  return (
    <BulkSystemPurposeModal
      key="bulk-system-purpose-modal"
      selectedCount={selectedCount}
      fetchBulkParams={fetchBulkParams}
      isOpen={modalOpen}
      closeModal={setModalClosed}
      orgId={orgId}
    />
  );
};

export default BulkSystemPurposeModalScene;
