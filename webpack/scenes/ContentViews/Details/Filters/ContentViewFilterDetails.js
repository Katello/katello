import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { shallowEqual, useSelector, useDispatch  } from 'react-redux';
import { STATUS } from 'foremanReact/constants';
import { Grid, GridItem } from '@patternfly/react-core';

import {
  selectCVFilterDetails,
  selectCVFilterDetailStatus,
  selectCVFilterDetailError,
} from '../ContentViewDetailSelectors';
import { getCVFilterDetails } from '../ContentViewDetailActions';
import useUrlParamsWithHash from '../../../../utils/useUrlParams';
import Loading from '../../../../components/Loading';
import ContentViewFilterDetailsHeader from './ContentViewFilterDetailsHeader';
import CVPackageGroupFilterContent from './CVPackageGroupFilterContent';

const ContentViewFilterDetails = () => {
  // TODO remove default params for testing
  const { id: cvId=1 } = useParams();
  const { params: { subContentId: filterId=1 } } = useUrlParamsWithHash();
  const dispatch = useDispatch();
  const [details, setDetails] = useState({});
  const response = useSelector(state => selectCVFilterDetails(state, cvId, filterId), shallowEqual);
  const status = useSelector(state => selectCVFilterDetailStatus(state, cvId, filterId), shallowEqual);
  const loaded = status === STATUS.RESOLVED;

  useEffect(() => {
    dispatch(getCVFilterDetails(cvId, filterId))
  }, [])

  useEffect(() => {
    if (loaded) setDetails(response);
  }, [JSON.stringify(response), loaded])

  const { type } = details;

  return (
    <Grid hasGutter>
      { loaded && details ?
        <ContentViewFilterDetailsHeader details={details} /> :
        <div>Loading...</div>
      }
      <GridItem span={12}>
        {
          {
            'package_group': <CVPackageGroupFilterContent cvId={cvId} filterId={filterId} />
          }[type] || <Loading />
        }
      </GridItem>
    </Grid>
  );
};

export default ContentViewFilterDetails;
