import React from 'react';
import PropTypes from 'prop-types';
import { Table } from 'react-bootstrap';

// using Map to preserve order
const displayMap = new Map([
  ['name', __('Name')],
  ['summary', __('Summary')],
  ['description', __('Description')],
  ['stream', __('Stream')],
  ['version', __('Version')],
  ['arch', __('Arch')],
  ['context', __('Context')],
  ['uuid', __('UUID')],
]);

const createRows = (details, mapping) => {
  const rows = [];
  /* eslint-disable no-restricted-syntax, react/jsx-closing-tag-location */
  for (const key of mapping.keys()) {
    rows.push(<tr key={key}>
      <td><b>{mapping.get(key)}</b></td>
      <td>{details[key]}</td>
    </tr>);
  }
  /* eslint-enable no-restricted-syntax, react/jsx-closing-tag-location */
  return rows;
};

const ModuleStreamDetailInfo = ({ moduleStreamDetails }) => (
  <Table>
    <tbody>
      {createRows(moduleStreamDetails, displayMap)}
    </tbody>
  </Table>
);

ModuleStreamDetailInfo.propTypes = {
  moduleStreamDetails: PropTypes.shape({}).isRequired,
};

export default ModuleStreamDetailInfo;
