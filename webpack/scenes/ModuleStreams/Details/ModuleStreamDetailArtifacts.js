import React from 'react';
import PropTypes from 'prop-types';

const ModuleStreamDetailArtifacts = ({ artifacts }) => (
  <div>
    <ul>
      {artifacts.map(artifact => <li key={artifact.id}>{artifact.name}</li>)}
    </ul>
  </div>
);

ModuleStreamDetailArtifacts.propTypes = {
  artifacts: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
};

export default ModuleStreamDetailArtifacts;
