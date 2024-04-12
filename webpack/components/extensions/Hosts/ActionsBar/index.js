import React, { useContext, useEffect } from 'react';
import { useDispatch } from 'react-redux';
import { DropdownItem } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { foremanUrl } from 'foremanReact/common/helpers';
import { ForemanHostsIndexActionsBarContext } from 'foremanReact/components/HostsIndex';
import { useForemanModal } from 'foremanReact/components/ForemanModal/ForemanModalHooks';
import { addModal } from 'foremanReact/components/ForemanModal/ForemanModalActions';
import { useForemanOrganization } from 'foremanReact/Root/Context/ForemanContext';

const HostActionsBar = () => {
  const {
    fetchBulkParams,
    selectedCount,
    selectAllMode,
  } = useContext(ForemanHostsIndexActionsBarContext);

  const dispatch = useDispatch();
  useEffect(() => {
    [
      'bulk-change-cv-modal',
      'bulk-packages-wizard',
    ].forEach((id) => {
      dispatch(addModal({ id }));
    });
  }, [dispatch]);
  const { setModalOpen: openBulkChangeCVModal } = useForemanModal({ id: 'bulk-change-cv-modal' });
  const { setModalOpen: openBulkPackagesWizardModal } = useForemanModal({ id: 'bulk-packages-wizard' });

  const orgId = useForemanOrganization()?.id;

  let href = '';
  if (selectAllMode) {
    const query = fetchBulkParams({ selectAllQuery: 'created_at < "1 second ago"' });
    href = foremanUrl(`/change_host_content_source?search=${query}`);
  } else if (selectedCount > 0) {
    href = foremanUrl(`/change_host_content_source?search=${fetchBulkParams()}`);
  }

  return (
    <>
      <DropdownItem
        ouiaId="change-content-s-dropdown-item"
        key="change-content-source-dropdown-item"
        href={href}
        isDisabled={selectedCount === 0}
      >
        {__('Change content source')}
      </DropdownItem>
      <DropdownItem
        ouiaId="bulk-change-cv-dropdown-item"
        key="bulk-change-cv-dropdown-item"
        onClick={openBulkChangeCVModal}
        isDisabled={selectedCount === 0 || !orgId}
      >
        {__('Change content view environments')}
      </DropdownItem>
      <DropdownItem
        ouiaId="bulk-packages-wizard-dropdown-item"
        key="bulk-packages-wizard-dropdown-item"
        onClick={openBulkPackagesWizardModal}
        isDisabled={selectedCount === 0}
      >
        {__('Manage packages')}
      </DropdownItem>
    </>
  );
};

export default HostActionsBar;
