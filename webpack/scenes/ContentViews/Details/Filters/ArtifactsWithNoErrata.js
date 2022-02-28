import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { Checkbox } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { editCVFilter } from '../ContentViewDetailActions';

export const ArtifactsWithNoErrataRenderer = ({ filterDetails }) => {
  const dispatch = useDispatch();
  const { id, inclusion, type } = filterDetails;

  const artifactAttribute = (type === 'modulemd') ? 'original_module_streams' : 'original_packages';
  const [artifactsNoErrata, enableArtifactsNoErrata] =
      useState(filterDetails[artifactAttribute] === true);

  const [isLoading, setLoading] = useState(false);

  const setArtifactsNoErrata = (checked) => {
    enableArtifactsNoErrata(checked);
    setLoading(true);
    dispatch(editCVFilter(id, { [artifactAttribute]: checked }, () => setLoading(false)));
  };
  const getLabel = () => {
    switch (true) {
    case type === 'modulemd' && inclusion:
      return __('Include all Module Streams with no errata.');
    case type === 'modulemd' && !inclusion:
      return __('Exclude all Module Streams with no errata.');
    case !inclusion:
      return __('Exclude all RPMs with no errata.');
    default:
      return __('Include all RPMs with no errata.');
    }
  };

  return (<Checkbox
    id="artifactsNoErrata"
    name="artifactsNoErrata"
    label=<p style={{ marginTop: '4px' }}>{getLabel()}</p>
    isChecked={artifactsNoErrata}
    isDisabled={isLoading}
    onChange={setArtifactsNoErrata}
  />);
};

ArtifactsWithNoErrataRenderer.propTypes = {
  filterDetails: PropTypes.shape({
    inclusion: PropTypes.bool.isRequired,
    type: PropTypes.string.isRequired,
    id: PropTypes.number.isRequired,
  }).isRequired,
};

export default ArtifactsWithNoErrataRenderer;
