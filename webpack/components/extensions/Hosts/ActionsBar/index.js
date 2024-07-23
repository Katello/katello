import React, { useContext, useEffect } from 'react';
import PropTypes from 'prop-types';
import { useDispatch } from 'react-redux';
import { Menu, MenuItem } from '@patternfly/react-core';
import { BanIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { foremanUrl } from 'foremanReact/common/helpers';
import { ForemanHostsIndexActionsBarContext } from 'foremanReact/components/HostsIndex';
import { useForemanModal } from 'foremanReact/components/ForemanModal/ForemanModalHooks';
import { addModal } from 'foremanReact/components/ForemanModal/ForemanModalActions';
import { useForemanOrganization } from 'foremanReact/Root/Context/ForemanContext';
import './ActionsBar.scss';

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

const HostActionsBar = () => {
  const {
    fetchBulkParams,
    selectedCount,
    selectAllMode,
    setMenuOpen,
  } = useContext(ForemanHostsIndexActionsBarContext);

  const dispatch = useDispatch();
  useEffect(() => {
    [
      'bulk-change-cv-modal',
      'bulk-packages-wizard',
      'bulk-errata-wizard',
    ].forEach((id) => {
      dispatch(addModal({ id }));
    });
  }, [dispatch]);
  const { setModalOpen: openBulkChangeCVModal } = useForemanModal({ id: 'bulk-change-cv-modal' });
  const { setModalOpen: openBulkPackagesWizardModal } = useForemanModal({ id: 'bulk-packages-wizard' });
  const { setModalOpen: openBulkErrataWizardModal } = useForemanModal({ id: 'bulk-errata-wizard' });

  const orgId = useForemanOrganization()?.id;

  let href = '';
  if (selectAllMode) {
    const query = fetchBulkParams({ selectAllQuery: 'created_at < "1 second ago"' });
    href = foremanUrl(`/change_host_content_source?search=${query}`);
  } else if (selectedCount > 0) {
    href = foremanUrl(`/change_host_content_source?search=${fetchBulkParams()}`);
  }

  return (
    <MenuItem
      itemId="content-flyout-item"
      key="content-flyout"
      isDisabled={selectedCount === 0}
      flyoutMenu={(
        <Menu ouiaId="content-flyout-menu" onSelect={() => setMenuOpen(false)}>
          <MenuItem
            itemId="bulk-packages-wizard-dropdown-item"
            key="bulk-packages-wizard-dropdown-item"
            onClick={openBulkPackagesWizardModal}
            isDisabled={selectedCount === 0 || !orgId}
            description={!orgId && <DisabledMenuItemDescription disabledReason={__('To manage host packages, a specific organization must be selected from the organization context.')} />}
          >
            {__('Packages')}
          </MenuItem>
          <MenuItem
            itemId="bulk-errata-wizard-dropdown-item"
            key="bulk-errata-wizard-dropdown-item"
            onClick={openBulkErrataWizardModal}
            isDisabled={selectedCount === 0}
          >
            {__('Errata')}
          </MenuItem>
          <MenuItem
            itemId="change-content-s-dropdown-item"
            key="change-content-source-dropdown-item"
            to={href}
            isDisabled={selectedCount === 0}
          >
            {__('Content source')}
          </MenuItem>
          <MenuItem
            itemId="bulk-change-cv-dropdown-item"
            key="bulk-change-cv-dropdown-item"
            onClick={openBulkChangeCVModal}
            isDisabled={selectedCount === 0 || !orgId}
            description={!orgId && <DisabledMenuItemDescription disabledReason={__('To change content view environments, a specific organization must be selected from the organization context.')} />}
          >
            {__('Content view environments')}
          </MenuItem>
        </Menu>
        )}
    >
      {__('Manage content')}
    </MenuItem>
  );
};

export default HostActionsBar;
