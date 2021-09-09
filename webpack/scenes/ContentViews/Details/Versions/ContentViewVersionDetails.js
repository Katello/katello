import React, { useEffect, useState } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { useParams } from 'react-router-dom';
import { useDispatch, useSelector, shallowEqual } from 'react-redux';
import { STATUS } from 'foremanReact/constants';
import { Grid } from '@patternfly/react-core';
import './ContentViewVersionDetails.scss';
import { editContentViewVersionDetails, getContentViewVersionDetails } from '../ContentViewDetailActions';
import useUrlParamsWithHash from '../../../../utils/useUrlParams';
import ContentViewVersionDetailsHeader from './ContentViewVersionDetailsHeader';
import { selectCVVersionDetails, selectCVVersionDetailsStatus } from '../ContentViewDetailSelectors';
import Loading from '../../../../components/Loading';

const ContentViewVersionDetails = () => {
  const { id: cvId } = useParams();
  const { params: { subContentId: versionId } } = useUrlParamsWithHash();
  const dispatch = useDispatch();
  const [details, setDetails] = useState({ });
  const response = useSelector(state =>
    selectCVVersionDetails(state, versionId, cvId), shallowEqual);
  const status = useSelector(state =>
    selectCVVersionDetailsStatus(state, versionId, cvId), shallowEqual);
  const loaded = status === STATUS.RESOLVED;

  const editDiscription = (val, attribute) => {
    const { description } = details;
    if (val !== description) {
      dispatch(editContentViewVersionDetails(
        versionId,
        cvId,
        { [attribute]: val },
        () => dispatch(getContentViewVersionDetails(versionId, cvId)),
      ));
    }
  };

  useEffect(() => {
    dispatch(getContentViewVersionDetails(versionId, cvId));
  }, [dispatch, versionId, cvId]);

  useDeepCompareEffect(() => {
    if (loaded) {
      setDetails(response);
    }
  }, [response, loaded]);

  if (!loaded) return <Loading />;
  return (
    <Grid>
      <ContentViewVersionDetailsHeader details={details} onEdit={editDiscription} />
    </Grid >
  );
};

export default ContentViewVersionDetails;
