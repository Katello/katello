import React from 'react';
import PropTypes from 'prop-types';
import { Tooltip } from '@patternfly/react-core';
import {
  BundleIcon,
  CodeIcon,
  FileIcon,
  BugIcon,
  FileImageIcon,
  FutbolIcon,
  MiddlewareIcon,
  QuestionIcon,
} from '@patternfly/react-icons';
import { sprintf, translate as __ } from 'foremanReact/common/I18n';

const RepositoryTypeIcon = ({ type }) => {
  const iconMap = {
    yum: BundleIcon,
    source_rpm: CodeIcon,
    file: FileIcon,
    debug: BugIcon,
    iso: FileImageIcon,
    kickstart: FutbolIcon,
    containerimage: MiddlewareIcon,
  };

  const Icon = iconMap[type] || QuestionIcon;

  return (
    <Tooltip content={type} position="bottom">
      <Icon aria-label={sprintf(__('%s repository type icon'), type)} size="lg" />
    </Tooltip>
  );
};

RepositoryTypeIcon.propTypes = {
  type: PropTypes.string.isRequired,
};

export default RepositoryTypeIcon;
