import React from 'react';
import PropTypes from 'prop-types';
import { Table } from 'react-bootstrap';
import { createRows } from '../../ModuleStreams/Details/ModuleStreamDetailInfo';

// using Map to preserve order
const displayMap = new Map([
  ['name', __('Name')],
  ['namespace', __('Namespace')],
  ['version', __('Version')],
  ['checksum', __('Checksum')],
  ['pulp_id', __('Pulp ID')],
]);

// const createRows = (details, mapping) => {
//   const rows = [];
//   /* eslint-disable no-restricted-syntax, react/jsx-closing-tag-location */
//   for (const key of mapping.keys()) {
//     rows.push(<tr key={key}>
//       <td><b>{mapping.get(key)}</b></td>
//       <td>{details[key]}</td>
//     </tr>);
//   }
//   /* eslint-enable no-restricted-syntax, react/jsx-closing-tag-location */
//   return rows;
// };

const AnsibleCollectionDetailInfo = ({ ansibleCollectionDetails }) => (
  <Table>
    <tbody>
      {createRows(ansibleCollectionDetails, displayMap)}
    </tbody>
  </Table>
);

AnsibleCollectionDetailInfo.propTypes = {
  ansibleCollectionDetails: PropTypes.shape({
    name: PropTypes.string,
    namespace: PropTypes.string,
    version: PropTypes.string,
    checksum: PropTypes.string,
    pulp_id: PropTypes.string,
  }).isRequired,
};

export default AnsibleCollectionDetailInfo;
