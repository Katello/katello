import React from 'react';
import PropTypes from 'prop-types';
import CVPackageGroupFilterContent from './CVPackageGroupFilterContent';
import CVRpmFilterContent from './CVRpmFilterContent';

const CVFilterDetailType = ({
  cvId, filterId, inclusion, type,
}) => {
  switch (type) {
    case 'package_group':
      return <CVPackageGroupFilterContent cvId={cvId} filterId={filterId} />;
    case 'rpm':
      return <CVRpmFilterContent filterId={filterId} inclusion={inclusion} />;
    default:
      return null;
  }
};

CVFilterDetailType.propTypes = {
  cvId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  filterId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  inclusion: PropTypes.bool,
  type: PropTypes.string,
};

CVFilterDetailType.defaultProps = {
  cvId: '',
  filterId: '',
  type: '',
  inclusion: false,
};

export default CVFilterDetailType;
