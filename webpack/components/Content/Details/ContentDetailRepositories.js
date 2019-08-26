import React from 'react';
import PropTypes from 'prop-types';
import { Table } from 'patternfly-react';
import TableSchema from './ContentDetailRepositoryTableSchema';

const ContentDetailRepositories = ({ repositories }) => (
  <div>
    <Table.PfProvider columns={TableSchema}>
      <Table.Header />
      <Table.Body rows={repositories} rowKey="id" />
    </Table.PfProvider>
  </div>
);

ContentDetailRepositories.propTypes = {
  repositories: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
};

export default ContentDetailRepositories;
