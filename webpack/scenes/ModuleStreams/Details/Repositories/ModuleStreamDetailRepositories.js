import React from 'react';
import PropTypes from 'prop-types';
import { Table } from 'patternfly-react';
import TableSchema from './TableSchema';

const ModuleStreamDetailRepositories = ({ repositories }) => (
  <div>
    <Table.PfProvider columns={TableSchema}>
      <Table.Header />
      <Table.Body rows={repositories} rowKey="id" />
    </Table.PfProvider>
  </div>
);

ModuleStreamDetailRepositories.propTypes = {
  repositories: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
};

export default ModuleStreamDetailRepositories;
