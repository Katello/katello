import React from 'react';
import PropTypes from 'prop-types';
import { Table } from 'react-bootstrap';

const displayMap = {
  name: 'Name',
  stream: 'Stream',
  version: 'Version',
  arch: 'Arch',
  context: 'Context',
  description: 'Description',
  summary: 'Summary',
  uuid: 'UUID',
};

const ModuleStreamDetailInfo = ({ moduleStreamDetails }) => (
  <Table>
    <tbody>
      {Object.keys(moduleStreamDetails).map(key => (
        Object.keys(displayMap).includes(key) &&
          <tr key={key}>
            <td><b>{__(displayMap[key])}</b></td>
            <td>{moduleStreamDetails[key]}</td>
          </tr>
      ))}
    </tbody>
  </Table>
);

ModuleStreamDetailInfo.propTypes = {
  moduleStreamDetails: PropTypes.shape({}).isRequired,
};

export default ModuleStreamDetailInfo;
