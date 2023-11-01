import React, { useContext } from 'react';
import { DropdownItem } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { foremanUrl } from 'foremanReact/common/helpers';
import { ForemanHostsIndexActionsBarContext } from 'foremanReact/components/HostsIndex';

const HostActionsBar = () => {
  const {
    fetchBulkParams,
    selectedCount,
    selectAllMode,
  } = useContext(ForemanHostsIndexActionsBarContext);

  let href = '';
  if (selectAllMode) {
    const query = fetchBulkParams({ selectAllQuery: 'created_at < "1 second ago"' });
    href = foremanUrl(`/change_host_content_source?search=${query}`);
  } else if (selectedCount > 0) {
    href = foremanUrl(`/change_host_content_source?search=${fetchBulkParams({})}`);
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
    </>
  );
};

export default HostActionsBar;
