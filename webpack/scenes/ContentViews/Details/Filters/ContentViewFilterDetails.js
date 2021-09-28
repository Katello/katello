import React, { useEffect, useState } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { useParams } from 'react-router-dom';
import { shallowEqual, useSelector, useDispatch } from 'react-redux';
import { STATUS } from 'foremanReact/constants';
import { Grid, GridItem } from '@patternfly/react-core';

import {
  selectCVFilterDetails,
  selectCVFilterDetailStatus,
} from '../ContentViewDetailSelectors';
import { getCVFilterDetails, getContentViewFilters } from '../ContentViewDetailActions';
import useUrlParamsWithHash from '../../../../utils/useUrlParams';
import ContentViewFilterDetailsHeader from './ContentViewFilterDetailsHeader';
import CVFilterDetailType from './CVFilterDetailType';
import Loading from '../../../../components/Loading';

const ContentViewFilterDetails = () => {
  const { id: cvId } = useParams();
  const { params: { subContentId: filterId } } = useUrlParamsWithHash();
  const dispatch = useDispatch();
  const [details, setDetails] = useState({});
  const [showAffectedRepos, setShowAffectedRepos] = useState(false);
  const response = useSelector(state => selectCVFilterDetails(state, cvId, filterId), shallowEqual);
  const status = useSelector(state =>
    selectCVFilterDetailStatus(state, cvId, filterId), shallowEqual);
  const loaded = status === STATUS.RESOLVED;
  const loading = status === STATUS.PENDING;

  useEffect(() => {
    dispatch(getCVFilterDetails(cvId, filterId));
    dispatch(getContentViewFilters(cvId));
  }, [dispatch, cvId, filterId]);

  useDeepCompareEffect(() => {
    if (loaded) {
      setDetails(response);
      const { repositories } = response;
      if (repositories.length) {
        setShowAffectedRepos(true);
      }
    }
  }, [response, loaded]);

  const { type, inclusion, rules } = details;
  if (loading) {
    return <Loading />;
  }
  return (
    <Grid hasGutter>
      {loaded && (Object.keys(details).length > 0) ?
        <ContentViewFilterDetailsHeader
          cvId={cvId}
          filterId={filterId}
          details={details}
          setShowAffectedRepos={setShowAffectedRepos}
        /> :
        <Loading />
      }
      <GridItem span={12}>
        <CVFilterDetailType
          cvId={cvId}
          filterId={filterId}
          inclusion={inclusion}
          type={type}
          showAffectedRepos={showAffectedRepos}
          setShowAffectedRepos={setShowAffectedRepos}
          rules={rules}
        />
      </GridItem>
    </Grid>
  );
};

export default ContentViewFilterDetails;
