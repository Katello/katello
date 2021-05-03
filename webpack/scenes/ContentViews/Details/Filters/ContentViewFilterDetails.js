import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { shallowEqual, useSelector, useDispatch } from 'react-redux';
import { STATUS } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';
import { Grid, GridItem } from '@patternfly/react-core';

import {
  selectCVFilterDetails,
  selectCVFilterDetailStatus,
} from '../ContentViewDetailSelectors';
import { getCVFilterDetails } from '../ContentViewDetailActions';
import useUrlParamsWithHash from '../../../../utils/useUrlParams';
import ContentViewFilterDetailsHeader from './ContentViewFilterDetailsHeader';
import CVFilterDetailType from './CVFilterDetailType';

const ContentViewFilterDetails = () => {
  const { id: cvId } = useParams();
  const { params: { subContentId: filterId } } = useUrlParamsWithHash();
  const dispatch = useDispatch();
  const [details, setDetails] = useState({});
  const response = useSelector(state => selectCVFilterDetails(state, cvId, filterId), shallowEqual);
  const status = useSelector(state =>
    selectCVFilterDetailStatus(state, cvId, filterId), shallowEqual);
  const loaded = status === STATUS.RESOLVED;

  useEffect(() => {
    dispatch(getCVFilterDetails(cvId, filterId));
  }, []);

  useEffect(() => {
    if (loaded) setDetails(response);
  }, [JSON.stringify(response), loaded]);

  const { type, inclusion } = details;

  return (
    <Grid hasGutter>
      { loaded && (Object.keys(details).length > 0) ?
        <ContentViewFilterDetailsHeader details={details} /> :
        <div>{__('Loading...')}</div>
      }
      <GridItem span={12}>
        <CVFilterDetailType cvId={cvId} filterId={filterId} inclusion={inclusion} type={type} />
      </GridItem>
    </Grid>
  );
};

export default ContentViewFilterDetails;
