import React from 'react';
import PropTypes from 'prop-types';
import { Table } from 'patternfly-react';
import TableSchema from './TableSchema';

const ModuleStreamDetailProfiles = ({ profiles }) => (
  <div>
    <Table.PfProvider columns={TableSchema}>
      <Table.Header />
      <Table.Body rows={profiles} rowKey="id" />
    </Table.PfProvider>
  </div>
);

ModuleStreamDetailProfiles.propTypes = {
  profiles: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
};

export default ModuleStreamDetailProfiles;
