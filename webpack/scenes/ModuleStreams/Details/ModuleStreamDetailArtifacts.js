import React from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';

const ModuleStreamDetailArtifacts = ({ artifacts }) => (
  <div>
    <ul>
      {artifacts.map(({ id, name }) => <li key={id}>{name}</li>)}
    </ul>
  </div>
);

ModuleStreamDetailArtifacts.propTypes = {
  artifacts: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
  })).isRequired,
};

export default ModuleStreamDetailArtifacts;
