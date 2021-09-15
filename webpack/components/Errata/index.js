import React from 'react';
import { TableText } from '@patternfly/react-table';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  BugIcon,
  SecurityIcon,
  EnhancementIcon,
} from '@patternfly/react-icons';
import PropTypes from 'prop-types';

export const ErrataType = ({ type }) => {
  let ErrataIcon;
  let label;
  switch (type) {
    case 'security':
      label = __('Security');
      ErrataIcon = SecurityIcon;
      break;
    case 'recommended':
    case 'bugfix':
      label = __('Bugfix');
      ErrataIcon = BugIcon;
      break;
    case 'enhancement':
    case 'optional':
      label = __('Enhancement');
      ErrataIcon = EnhancementIcon;
      break;
    default:
  }
  if (!ErrataIcon) return null;

  return (
    <TableText wrapModifier="nowrap">
      <ErrataIcon title={label} /> {label}
    </TableText>
  );
};

ErrataType.propTypes = {
  type: PropTypes.string.isRequired,
};

export const ErrataSeverity = ({ severity }) => {
  let color;
  let label;

  switch (severity) {
    case 'Moderate':
      color = 'yellow';
      label = __('Moderate');
      break;
    case 'Important':
      color = 'orange';
      label = __('Important');
      break;
    case 'Critical':
      color = 'red';
      label = __('Critical');
      break;
    default:
      label = __('N/A');
  }
  return <TableText wrapModifier="nowrap">{color && <SecurityIcon color={color} title={label} />} {label} </TableText>;
};

ErrataSeverity.propTypes = {
  severity: PropTypes.string.isRequired,
};
