import React from 'react';
import PropTypes from 'prop-types';
import { Table } from 'react-bootstrap';
import { translate as __ } from 'foremanReact/common/I18n';

// using Map to preserve order

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

const ContentDetailInfo = ({ contentDetails, displayMap }) => (
  <Table>
    <tbody>
    {createRows(contentDetails, displayMap)}
    </tbody>
  </Table>
);

ContentDetailInfo.propTypes = {
  contentDetails: PropTypes.shape({
    name: PropTypes.string,
    summary: PropTypes.string,
    description: PropTypes.string,
    stream: PropTypes.string,
    version: PropTypes.string,
    arch: PropTypes.string,
    context: PropTypes.string,
    uuid: PropTypes.string,
  }).isRequired,
};

export default ContentDetailInfo;
