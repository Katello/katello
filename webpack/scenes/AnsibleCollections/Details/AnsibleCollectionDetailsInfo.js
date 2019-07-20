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
