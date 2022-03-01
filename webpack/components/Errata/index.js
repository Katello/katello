import React from 'react';
import { TableText } from '@patternfly/react-table';
import {
  chart_color_black_500 as pfBlack,
  chart_color_gold_400 as pfGold,
  chart_color_orange_300 as pfOrange,
  chart_color_red_200 as pfRed,
} from '@patternfly/react-tokens';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  BugIcon,
  SecurityIcon,
  EnhancementIcon,
  SquareIcon,
} from '@patternfly/react-icons';
import PropTypes from 'prop-types';

export const ErrataMapper = ({ data, id }) => data.map(({ x: type, y: count }) => <ErrataSummary count={count} type={type} key={`${count} ${type}`} id={id} />);

export const ErrataSummary = ({ type, count }) => {
  let ErrataIcon;
  let label;
  let name;
  let url;
  let color;
  switch (type) {
  case 'security':
    label = __('Security');
    ErrataIcon = SecurityIcon;
    name = 'security advisories';
    color = '#0066cc';
    url = <a href="#/Content/errata?type=security"> {count} {name} </a>;
    break;
  case 'recommended':
  case 'bugfix':
    label = __('Bugfix');
    ErrataIcon = BugIcon;
    name = 'bug fixes';
    color = '#8bc1f7';
    url = <a href="#/Content/errata?type=bugfix"> {count} {name} </a>;
    break;
  case 'enhancement':
  case 'optional':
    label = __('Enhancement');
    ErrataIcon = EnhancementIcon;
    name = 'enhancements';
    color = '#002f5d';
    url = <a href="#/Content/errata?type=enhancement"> {count} {name} </a>;
    break;
  default:
  }
  if (!ErrataIcon) return null;

  return (
    <span style={{ whiteSpace: 'normal', fontSize: 'small' }}>
      <TableText>
        <SquareIcon size="sm" color={color} />
        <span style={{ marginLeft: '8px' }}>
          <ErrataIcon title={label} />
          {url}
        </span>
      </TableText>
    </span>
  );
};

ErrataSummary.propTypes = {
  type: PropTypes.string.isRequired,
  count: PropTypes.number.isRequired,
};

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
  case 'Low':
    color = pfBlack.value;
    label = __('Low');
    break;
  case 'Moderate':
    color = pfGold.value;
    label = __('Moderate');
    break;
  case 'Important':
    color = pfOrange.value;
    label = __('Important');
    break;
  case 'Critical':
    color = pfRed.value;
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
