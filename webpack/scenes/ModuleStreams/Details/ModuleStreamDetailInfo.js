import React from 'react';
import PropTypes from 'prop-types';
import { Table } from 'react-bootstrap';

const displayMap = {
  name: __('Name'),
  stream: __('Stream'),
  version: __('Version'),
  arch: __('Arch'),
  context: __('Context'),
  description: __('Description'),
  summary: __('Summary'),
  uuid: __('UUID'),
};

const ModuleStreamDetailInfo = ({ moduleStreamDetails }) => (
  <Table>
    <tbody>
      {Object.keys(moduleStreamDetails).map(key => (
        Object.keys(displayMap).includes(key) &&
          <tr key={key}>
            <td><b>{displayMap[key]}</b></td>
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
