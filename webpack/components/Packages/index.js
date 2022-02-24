import React from 'react';
import { TableText } from '@patternfly/react-table';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  CheckIcon,
  LongArrowAltUpIcon,
} from '@patternfly/react-icons';
import PropTypes from 'prop-types';

export const PackagesStatus = ({ upgradable_version: upgradableVersion }) => {
  let PackagesIcon;
  let label;
  let color;

  if (upgradableVersion == null) {
    color = 'green';
    label = __('Up-to date');
    PackagesIcon = CheckIcon;
  } else {
    color = 'blue';
    label = __('Upgradable');
    PackagesIcon = LongArrowAltUpIcon;
  }
  if (!PackagesIcon) return null;

  return (
    <TableText wrapModifier="nowrap">
      {color && <PackagesIcon color={color} title={label} />} {label}
    </TableText>
  );
};

PackagesStatus.propTypes = {
  upgradable_version: PropTypes.string,
};

PackagesStatus.defaultProps = {
  upgradable_version: null,
};

export const PackagesLatestVersion = ({ name, upgradable_version: upgradableVersion }) => {
  let label;

  if (upgradableVersion == null) {
    label = '';
  } else {
    label = upgradableVersion.replace(`${name}-`, '');
  }

  return <TableText wrapModifier="nowrap">{label || '—'} </TableText>;
};

PackagesLatestVersion.propTypes = {
  name: PropTypes.string.isRequired,
  upgradable_version: PropTypes.string,
};

PackagesLatestVersion.defaultProps = {
  upgradable_version: null,
};
