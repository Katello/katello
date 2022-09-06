import React from 'react';
import { TableText } from '@patternfly/react-table';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  CheckIcon,
  LongArrowAltUpIcon,
} from '@patternfly/react-icons';
import PropTypes from 'prop-types';

const PackagesStatus = ({ upgradable_versions: upgradableVersions }) => {
  let PackagesIcon;
  let label;
  let color;

  if (upgradableVersions === null) {
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
  upgradable_versions: PropTypes.arrayOf(PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.arrayOf(PropTypes.string),
  ])),
};

PackagesStatus.defaultProps = {
  upgradable_versions: null,
};

export default PackagesStatus;
