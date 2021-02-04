import React from 'react';
import { Tooltip } from '@patternfly/react-core';
import { BundleIcon, MiddlewareIcon, BoxIcon, CodeBranchIcon, FanIcon, TenantIcon } from '@patternfly/react-icons';
import PropTypes from 'prop-types';

const RepoIcon = ({ type }) => {
  const iconMap = {
    yum: BundleIcon,
    docker: MiddlewareIcon,
    ostree: CodeBranchIcon,
    file: TenantIcon,
    deb: FanIcon,
  };
  const Icon = iconMap[type] || BoxIcon;

  return <Tooltip content={<div>{type}</div>}><Icon /></Tooltip>;
};

RepoIcon.propTypes = {
  type: PropTypes.string,
};

RepoIcon.defaultProps = {
  type: "" // prevent errors if data isn't loaded yet
}

export default RepoIcon;
