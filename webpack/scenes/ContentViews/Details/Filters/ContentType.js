import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';

import RepoIcon from '../Repositories/RepoIcon';
import { capitalize, repoType } from '../../../../utils/helpers';

export const typeName = (type, errataByDate) => {
  if (errataByDate) return 'Errata - by date range';
  const nameMap = {
    rpm: __('RPM'),
    docker: __('Container image tag'),
    modulemd: __('Module stream'),
    erratum: __('Errata'),
    erratum_date: __('Errata - by date range'),
    erratum_id: __('Errata'),
  };

  if (type in nameMap) return nameMap[type];
  return capitalize(type.replace('_', ' '));
};

const ContentType = ({ type, errataByDate }) => (
  <Fragment>
    <span style={{ marginRight: '5px' }}><RepoIcon type={repoType(type)} /></span>
    {typeName(type, errataByDate)}
  </Fragment>
);

ContentType.propTypes = {
  type: PropTypes.string.isRequired,
  errataByDate: PropTypes.bool,
};

ContentType.defaultProps = {
  errataByDate: false,
};

export default ContentType;
