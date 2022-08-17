import React from 'react';
import { useSelector } from 'react-redux';
import { DropdownItem } from '@patternfly/react-core';
import { CubeIcon, UndoIcon } from '@patternfly/react-icons';

import { translate as __ } from 'foremanReact/common/I18n';
import { foremanUrl } from 'foremanReact/common/helpers';

import { selectHostDetails } from '../HostDetailsSelectors';

const HostActionsBar = () => {
  const hostDetails = useSelector(selectHostDetails);

  return (
    <>
      <DropdownItem
        key="katello-legacy-contenthost-ui"
        href={foremanUrl(`/content_hosts/${hostDetails?.id}`)}
        icon={<UndoIcon />}
      >
        {__('Legacy content host UI')}
      </DropdownItem>
      <DropdownItem
        key="katello-change-host-content-source"
        href={foremanUrl(`/change_host_content_source?host_id=${hostDetails?.id}`)}
        icon={<CubeIcon />}
      >
        {__('Change content source')}
      </DropdownItem>
    </>
  );
};

export default HostActionsBar;
