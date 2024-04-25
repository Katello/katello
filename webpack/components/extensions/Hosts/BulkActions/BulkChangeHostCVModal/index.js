import React, { useContext } from 'react';
import { useForemanOrganization } from 'foremanReact/Root/Context/ForemanContext';
import { ForemanActionsBarContext } from 'foremanReact/components/HostDetails/ActionsBar';
import { useForemanModal } from 'foremanReact/components/ForemanModal/ForemanModalHooks';
import BulkChangeHostCVModal from './BulkChangeHostCVModal';

const BulkChangeHostCVModalScene = () => {
  const org = useForemanOrganization();
  const { selectedCount, fetchBulkParams } = useContext(ForemanActionsBarContext);
  const { modalOpen, setModalClosed } = useForemanModal({ id: 'bulk-change-cv-modal' });

  return (
    <BulkChangeHostCVModal
      key="bulk-change-cv-modal"
      selectedCount={selectedCount}
      fetchBulkParams={fetchBulkParams}
      isOpen={modalOpen}
      closeModal={setModalClosed}
      orgId={org?.id}
    />

  );
};

export default BulkChangeHostCVModalScene;
