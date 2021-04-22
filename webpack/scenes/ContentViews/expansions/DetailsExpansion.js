import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';

const DetailsExpansion = ({ cvId, activationKeys, hosts }) => {
  const activationKeyCount = activationKeys.length;
  const hostCount = hosts.length;

  return (
    <div id={`cv-details-expansion-${cvId}`}>
      {__('Activation keys: ')}<a aria-label={`activation_keys_link_${cvId}`} href={`/activation_keys?search=content_view_id+%3D+${cvId}`}>{activationKeyCount}</a>
      <br />
      {__('Hosts: ')}<a aria-label={`host_link_${cvId}`} href={`/hosts?search=content_view_id+%3D+${cvId}`}>{hostCount}</a>
    </div>
  );
};

DetailsExpansion.propTypes = {
  cvId: PropTypes.number.isRequired,
  activationKeys: PropTypes.arrayOf(PropTypes.shape({})),
  hosts: PropTypes.arrayOf(PropTypes.shape({})),
};

DetailsExpansion.defaultProps = {
  activationKeys: [],
  hosts: [],
};

export default DetailsExpansion;
