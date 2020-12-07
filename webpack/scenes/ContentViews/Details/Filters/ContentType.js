import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';

import RepoIcon from '../Repositories/RepoIcon';
import { capitalize } from '../../../../utils/helpers';

const typeName = (type, errataByDate) => {
  if (errataByDate) return 'Errata - by date range';
  const nameMap = {
    rpm: __('RPM'),
    docker: __('Container image tag'),
    modulemd: __('Module stream'),
    erratum: __('Errata'),
  };

  if (Object.prototype.hasOwnProperty.call(nameMap, type)) return nameMap[type];
  return capitalize(type.replace('_', ' '));
};

const ContentType = ({ type, errataByDate }) => {
  const repoType = ['rpm', 'modulemd', 'rpm', 'erratum', 'package_group'].includes(type) ? 'yum' : type;
  return (
    <Fragment>
      <span style={{ marginRight: '5px' }}><RepoIcon type={repoType} /></span>
      {typeName(type, errataByDate)}
    </Fragment>
  );
};

ContentType.propTypes = {
  type: PropTypes.string.isRequired,
  errataByDate: PropTypes.bool,
};

ContentType.defaultProps = {
  errataByDate: false,
};

export default ContentType;
