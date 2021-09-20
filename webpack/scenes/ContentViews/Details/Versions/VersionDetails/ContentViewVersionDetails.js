import React, { useEffect, useState } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { useParams, HashRouter, Route, useHistory, useLocation, Redirect, Switch } from 'react-router-dom';
import { useDispatch, useSelector, shallowEqual } from 'react-redux';
import { STATUS } from 'foremanReact/constants';
import { isEmpty, camelCase, first } from 'lodash';
import { Grid, Tabs, Tab, TabTitleText, Label } from '@patternfly/react-core';
import './ContentViewVersionDetails.scss';

import { editContentViewVersionDetails, getContentViewVersionDetails } from '../../ContentViewDetailActions';
import ContentViewVersionDetailsHeader from './ContentViewVersionDetailsHeader';
import { selectCVVersionDetails, selectCVVersionDetailsStatus } from '../../ContentViewDetailSelectors';
import getCVVersionTableConfigs from './ContentViewVersionDetailConfig.js';
import ContentViewVersionDetailsTable from './ContentViewVersionDetailsTable';
import Loading from '../../../../../components/Loading';

const ContentViewVersionDetails = () => {
  const { id: cvId, versionId } = useParams();
  const { hash, key } = useLocation();
  const { push } = useHistory();
  const dispatch = useDispatch();
  const [details, setDetails] = useState({});
  const response = useSelector(state =>
    selectCVVersionDetails(state, versionId, cvId), shallowEqual);
  const status = useSelector(state =>
    selectCVVersionDetailsStatus(state, versionId, cvId), shallowEqual);
  const loaded = status === STATUS.RESOLVED;
  const tableConfigs = getCVVersionTableConfigs({ cvId, versionId });

  useEffect(() => {
    dispatch(getContentViewVersionDetails(versionId, cvId));
  }, [dispatch, versionId, cvId]);

  useDeepCompareEffect(() => {
    if (loaded) {
      setDetails(response);
    }
  }, [response, loaded, tableConfigs]);

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

  const onSelect = (_e, eventKey) => {
    // This prevents needless pushing on repeated clicks of a tab
    if (hash.slice(1) !== eventKey) {
      push(`#${eventKey}`);
    }
  };

  // Checking details is done to prevent two renders of the table.
  if (!loaded && isEmpty(details)) return <Loading />;
  const filteredTableConfigs = tableConfigs.filter(({ getCountKey }) => !!getCountKey(response));
  const showTabs = filteredTableConfigs.length > 0;
  const getCurrentActiveKey = hash?.slice(1) || camelCase(first(filteredTableConfigs)?.name);

  return (
    <Grid>
      <ContentViewVersionDetailsHeader details={details} onEdit={editDiscription} />
      {showTabs &&
        <div className="grid-with-top-border">
          <Tabs
            activeKey={getCurrentActiveKey}
            onSelect={onSelect}
            isVertical
          >
            {filteredTableConfigs.map(({ name, getCountKey }) => (
              <Tab
                key={name}
                eventKey={camelCase(name)}
                title={
                  <>
                    <TabTitleText>{name}</TabTitleText>
                    <Label color="grey">{getCountKey(response)}</Label>
                  </>
                }
              />
            ))}
          </Tabs>
          <HashRouter
            hashType="noslash" // This produces /#tab instead of /#/tab
            key={key} // This key is needed to repaint the route for the table
          >
            <Switch>
              {filteredTableConfigs.map(config => (
                <Route key={camelCase(config.name)} exact path={`/${camelCase(config.name)}`}>
                  <ContentViewVersionDetailsTable
                    tableConfig={config}
                  />
                </Route>))
              }
              <Redirect to={`/${camelCase(first(filteredTableConfigs).name)}`} />
            </Switch>
          </HashRouter>
        </div>
      }
    </Grid >
  );
};

export default ContentViewVersionDetails;
