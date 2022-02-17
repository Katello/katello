import React, { useEffect, useState } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { useParams, Route, useHistory, useLocation, Redirect, Switch } from 'react-router-dom';
import { useDispatch, useSelector, shallowEqual } from 'react-redux';
import { STATUS } from 'foremanReact/constants';
import { isEmpty, first } from 'lodash';
import { Grid, Tabs, Tab, TabTitleText, Label } from '@patternfly/react-core';
import { number, shape } from 'prop-types';
import './ContentViewVersionDetails.scss';

import { editContentViewVersionDetails, getContentViewVersionDetails } from '../../ContentViewDetailActions';
import ContentViewVersionDetailsHeader from './ContentViewVersionDetailsHeader';
import { selectCVVersionDetails, selectCVVersionDetailsStatus } from '../../ContentViewDetailSelectors';
import getCVVersionTableConfigs from './ContentViewVersionDetailConfig.js';
import ContentViewVersionDetailsTable from './ContentViewVersionDetailsTable';
import Loading from '../../../../../components/Loading';

const ContentViewVersionDetails = ({ cvId, details }) => {
  const { versionId } = useParams();
  const { pathname } = useLocation();
  const { push } = useHistory();
  const dispatch = useDispatch();
  const [versionDetails, setVersionDetails] = useState({});
  const [mounted, setMounted] = useState(true);
  // Example urls expected:/versions/:id or /versions/:id/repositories.
  const tab = pathname.split('/')[3];
  const response = useSelector(state =>
    selectCVVersionDetails(state, versionId, cvId), shallowEqual);
  const status = useSelector(state =>
    selectCVVersionDetailsStatus(state, versionId, cvId), shallowEqual);
  const loaded = status === STATUS.RESOLVED;
  const tableConfigs = getCVVersionTableConfigs({ cvId, versionId });

  useEffect(() => {
    if (mounted || (isEmpty(response) && status === STATUS.PENDING)) {
      dispatch(getContentViewVersionDetails(versionId, cvId));
    }
    return () => { setMounted(false); };
  }, [dispatch, mounted, setMounted, versionId, cvId, response, status]);

  useDeepCompareEffect(() => {
    if (loaded) {
      setVersionDetails(response);
    }
  }, [response, loaded, tableConfigs]);

  const editDiscription = (val, attribute) => {
    const { description } = versionDetails;
    if (val !== description) {
      dispatch(editContentViewVersionDetails(
        versionId,
        cvId,
        { [attribute]: val },
        () => dispatch(getContentViewVersionDetails(versionId, cvId)),
      ));
    }
  };

  const onSelect = (_e, eventKey) => {
    // This prevents needless pushing on repeated clicks of a tab
    if (tab !== eventKey) {
      push(eventKey);
    }
  };

  // Checking versionDetails is done to prevent two renders of the table.
  if (!loaded && isEmpty(versionDetails)) return <Loading />;
  const filteredTableConfigs = tableConfigs.filter(({ getCountKey }) => !!getCountKey(response));
  const { repositories } = versionDetails;
  const showTabs = filteredTableConfigs.length > 0 && repositories;
  const getCurrentActiveKey = tab ?? first(filteredTableConfigs)?.route;

  return (
    <Grid>
      <ContentViewVersionDetailsHeader
        versionDetails={versionDetails}
        onEdit={editDiscription}
        details={details}
      />
      {showTabs &&
        <div className="grid-with-top-border">
          <Tabs
            activeKey={getCurrentActiveKey}
            onSelect={onSelect}
            isVertical
          >
            {filteredTableConfigs.map(({ route, name, getCountKey }) => (
              <Tab
                key={route}
                eventKey={route}
                title={
                  <>
                    <TabTitleText>{name}</TabTitleText>
                    <Label color="grey">{getCountKey(response)}</Label>
                  </>
                }
              />
            ))}
          </Tabs>
          <Switch>
            {filteredTableConfigs.map(config => (
              <Route
                key={config.route}
                exact
                path={`/versions/:versionId([0-9]+)/${config.route}`}
              >
                <ContentViewVersionDetailsTable
                  tableConfig={config}
                  repositories={repositories}
                />
              </Route>))
            }
            <Redirect
              to={`/versions/${versionId}/${first(filteredTableConfigs).route}`}
            />
          </Switch>
        </div>
      }
    </Grid >
  );
};

ContentViewVersionDetails.propTypes = {
  cvId: number.isRequired,
  details: shape({
    permissions: shape({}),
  }).isRequired,
};

export default ContentViewVersionDetails;
