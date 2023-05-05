import React from 'react';
import PropTypes from 'prop-types';
import { Table } from 'react-bootstrap';

// using Map to preserve order

const createRows = (details, mapping) => {
  const rows = [];
  /* eslint-disable no-restricted-syntax, react/jsx-closing-tag-location */
  for (const key of mapping.keys()) {
    rows.push(<tr key={key}>
      <td><b>{mapping.get(key)}</b></td>
      <td>{Array.isArray(details[key]) ? details[key].join(', ') : details[key]}</td>
    </tr>);
  }
  /* eslint-enable no-restricted-syntax, react/jsx-closing-tag-location */
  return rows;
};

const ContentDetailInfo = ({ contentDetails, displayMap }) => (
  <Table ouiaId="content-details-info-table">
    <tbody>
      {createRows(contentDetails, displayMap)}
    </tbody>
  </Table>
);

ContentDetailInfo.propTypes = {
  contentDetails: PropTypes.shape({}).isRequired,
  displayMap: PropTypes.instanceOf(Map).isRequired,
};

export default ContentDetailInfo;
