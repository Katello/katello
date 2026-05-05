import React, { useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { STATUS } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';
import { selectContentDetails, selectContentDetailsStatus } from '../../Content/ContentSelectors';
import { getContentDetails } from '../../Content/ContentActions';
import Loading from '../../../components/Loading';

const ModuleStreamDetailArtifacts = ({ contentType, id }) => {
  const dispatch = useDispatch();
  const detailsResponse = useSelector(selectContentDetails);
  const detailsStatus = useSelector(selectContentDetailsStatus);

  useEffect(() => {
    if (!detailsResponse) {
      dispatch(getContentDetails(contentType, id));
    }
  });

  if (detailsStatus === STATUS.PENDING) {
    return <Loading />;
  }

  const { artifacts } = detailsResponse || {};

  if (!artifacts || artifacts.length === 0) {
    return <div className="margin-0-24">{__('No artifacts to show')}</div>;
  }

  return (
    <div className="margin-0-24">
      <ul>
        {artifacts.map(({ id: artifactId, name }) => <li key={artifactId}>{name}</li>)}
      </ul>
    </div>
  );
};

ModuleStreamDetailArtifacts.propTypes = {
  contentType: PropTypes.string.isRequired,
  id: PropTypes.number.isRequired,
};

export default ModuleStreamDetailArtifacts;
