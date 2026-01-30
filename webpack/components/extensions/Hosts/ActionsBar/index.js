import React, { useContext } from 'react';
import PropTypes from 'prop-types';
import { Menu, MenuItem, MenuContent, MenuList } from '@patternfly/react-core';
import { BanIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { foremanUrl } from 'foremanReact/common/helpers';
import { ForemanHostsIndexActionsBarContext } from 'foremanReact/components/HostsIndex';
import { useForemanOrganization, useForemanContext } from 'foremanReact/Root/Context/ForemanContext';
import './ActionsBar.scss';
import { openBulkModal } from '../BulkActions/bulkModalState';


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

  const orgId = useForemanOrganization()?.id;
  const foremanContext = useForemanContext();
  const allowMultipleContentViews =
    foremanContext?.metadata?.katello?.allow_multiple_content_views ?? true;

  let href = '';
  if (selectAllMode) {
    const query = fetchBulkParams({ selectAllQuery: 'created_at < "1 second ago"' });
    href = foremanUrl(`/change_host_content_source?search=${query}`);
  } else if (selectedCount > 0) {
    href = foremanUrl(`/change_host_content_source?search=${fetchBulkParams()}`);
  }

  const handleOpenBulkModal = (modalId) => {
    setMenuOpen(false);
    setTimeout(() => openBulkModal(modalId, true), 0);
  };

  return (
    <>
      <MenuItem
        itemId="content-flyout-item"
        key="content-flyout"
        isDisabled={selectedCount === 0}
        flyoutMenu={(
          <Menu ouiaId="content-flyout-menu" onSelect={() => setMenuOpen(false)}>
            <MenuContent>
              <MenuList>
                <MenuItem
                  itemId="bulk-packages-wizard-dropdown-item"
                  key="bulk-packages-wizard-dropdown-item"
                  onClick={() => handleOpenBulkModal('bulk-packages-wizard')}
                  isDisabled={selectedCount === 0 || !orgId}
                  description={!orgId && <DisabledMenuItemDescription disabledReason={__('To manage host packages, a specific organization must be selected from the organization context.')} />}
                >
                  {__('Packages')}
                </MenuItem>
                <MenuItem
                  itemId="bulk-errata-wizard-dropdown-item"
                  key="bulk-errata-wizard-dropdown-item"
                  onClick={() => handleOpenBulkModal('bulk-errata-wizard')}
                  isDisabled={selectedCount === 0}
                >
                  {__('Errata')}
                </MenuItem>
                <MenuItem
                  itemId="bulk-repo-sets-wizard-dropdown-item"
                  key="bulk-repo-sets-wizard-dropdown-item"
                  onClick={() => handleOpenBulkModal('bulk-repo-sets-wizard')}
                  isDisabled={selectedCount === 0 || !orgId}
                  description={!orgId && <DisabledMenuItemDescription disabledReason={__('To manage host content overrides, a specific organization must be selected from the organization context.')} />}
                >
                  {__('Repository sets')}
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
                  itemId="bulk-assign-cves-dropdown-item"
                  key="bulk-assign-cves-dropdown-item"
                  onClick={() => handleOpenBulkModal('bulk-assign-cves-modal')}
                  isDisabled={selectedCount === 0 || !orgId}
                  description={!orgId && <DisabledMenuItemDescription disabledReason={__('To assign content view environment(s), a specific organization must be selected from the organization context.')} />}
                >
                  {allowMultipleContentViews ? __('Content view environments') : __('Content view environment')}
                </MenuItem>
                <MenuItem
                  itemId="bulk-system-purpose-dropdown-item"
                  key="bulk-system-purpose-dropdown-item"
                  onClick={() => handleOpenBulkModal('bulk-system-purpose-modal')}
                  isDisabled={selectedCount === 0 || !orgId}
                  description={!orgId && <DisabledMenuItemDescription disabledReason={__('To change system purpose, a specific organization must be selected from the organization context.')} />}
                >
                  {__('System purpose')}
                </MenuItem>
              </MenuList>
            </MenuContent>
          </Menu>
          )}
      >
        {__('Manage content')}
      </MenuItem>
      <MenuItem
        itemId="bulk-manage-traces-menu-item"
        key="bulk-manage-traces-menu-item"
        onClick={() => handleOpenBulkModal('bulk-manage-traces-modal')}
        isDisabled={selectedCount === 0 || !orgId}
        description={!orgId && <DisabledMenuItemDescription disabledReason={__('To manage traces, a specific organization must be selected from the organization context.')} />}
      >
        {__('Manage traces')}
      </MenuItem>
    </>
  );
};

export default HostActionsBar;
