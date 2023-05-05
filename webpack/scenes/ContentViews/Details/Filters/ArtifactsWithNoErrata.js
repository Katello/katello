import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { Switch } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { editCVFilter } from '../ContentViewDetailActions';
import { CONTENT_VIEW_NEEDS_PUBLISH } from '../../ContentViewsConstants';

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
    dispatch(editCVFilter(id, { [artifactAttribute]: checked }, () => {
      setLoading(false);
      dispatch({ type: CONTENT_VIEW_NEEDS_PUBLISH });
    }));
  };
  const getLabel = () => {
    switch (true) {
    case type === 'modulemd' && inclusion:
      return __('Include all module streams not associated to any errata');
    case type === 'modulemd' && !inclusion:
      return __('Exclude all module streams not associated to any errata');
    case !inclusion:
      return __('Exclude all RPMs not associated to any errata');
    default:
      return __('Include all RPMs not associated to any errata');
    }
  };

  return (<Switch
    ouiaId="artifactsNoErrata"
    id="artifactsNoErrata"
    name="artifactsNoErrata"
    label={getLabel()}
    isChecked={artifactsNoErrata}
    isDisabled={isLoading}
    onChange={checked => setArtifactsNoErrata(checked)}
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
