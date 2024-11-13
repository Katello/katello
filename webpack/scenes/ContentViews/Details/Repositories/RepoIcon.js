import React from 'react';
import { Tooltip } from '@patternfly/react-core';
import { BundleIcon, MiddlewareIcon, BoxIcon, CodeBranchIcon, FanIcon, TenantIcon, AnsibleTowerIcon } from '@patternfly/react-icons';
import PropTypes from 'prop-types';

const RepoIcon = ({ type, customTooltip }) => {
  const iconMap = {
    yum: BundleIcon,
    docker: MiddlewareIcon,
    ostree: CodeBranchIcon,
    file: TenantIcon,
    deb: FanIcon,
    ansible_collection: AnsibleTowerIcon,
  };
  const Icon = iconMap[type] || BoxIcon;

  return <Tooltip content={<div>{customTooltip ?? type}</div>}><Icon aria-label={`${type}_type_icon`} /></Tooltip>;
};

RepoIcon.propTypes = {
  type: PropTypes.string,
  customTooltip: PropTypes.string,
};

RepoIcon.defaultProps = {
  type: '', // prevent errors if data isn't loaded yet
  customTooltip: null,
};

export default RepoIcon;
