import React, { useState, useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';

import { Alert, Grid, GridItem, List, ListItem } from '@patternfly/react-core';

import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import { foremanUrl } from 'foremanReact/common/helpers';

import { selectApiDataStatus,
  selectApiContentViewStatus,
  selectApiChangeContentStatus,
  selectContentHostsIds,
  selectHostsWithoutContent,
  selectEnvironments,
  selectContentSources,
  selectJobInvocationPath,
  selectContentViews,
  selectTemplate } from './selectors';
import { getHostIds, formIsLoading } from './helpers';
import { getFormData, changeContentSource, getContentViews } from './actions';
import ContentSourceForm from './components/ContentSourceForm';
import ContentSourceTemplate from './components/ContentSourceTemplate';
import './styles.scss';

const ChangeContentSourcePage = () => {
  const dispatch = useDispatch();

  const apiDataStatus = useSelector(selectApiDataStatus);
  const apiContentViewStatus = useSelector(selectApiContentViewStatus);
  const apiChangeStatus = useSelector(selectApiChangeContentStatus);

  const isLoading = formIsLoading(apiDataStatus, apiContentViewStatus, apiChangeStatus);

  const contentHostsIds = useSelector(selectContentHostsIds);
  const hostsWithoutContent = useSelector(selectHostsWithoutContent);
  const environments = useSelector(selectEnvironments);
  const contentSources = useSelector(selectContentSources);
  const jobInvocationPath = useSelector(selectJobInvocationPath);

  const template = useSelector(selectTemplate);
  const contentViews = useSelector(selectContentViews);

  const [environmentId, setEnvironmentId] = useState();
  const [contentViewId, setContentViewId] = useState();
  const [contentSourceId, setContentSourceId] = useState();

  const handleSubmit = (e) => {
    e.preventDefault();

    dispatch(changeContentSource(environmentId, contentViewId, contentSourceId, contentHostsIds));
  };

  const handleEnvironment = (envId) => {
    if (envId) {
      dispatch(getContentViews(envId));
    }

    setEnvironmentId(envId);
    setContentViewId('');
  };

  const IgnoredHostsAlert = () => (
    <Alert
      variant="warning"
      title={__('Some hosts are ignored!')}
      className="cs_alert"
      isExpandable
    >
      <p>
        { __('The following hosts are not registered as Content Hosts, so they will be ignored:') }
      </p>
      { hostsWithoutContent.map(name => (
        <List>
          <ListItem>
            <a href={foremanUrl(`/hosts/${name}`)}>{name}</a>
          </ListItem>
        </List>))}
    </Alert>);

  useEffect(() => {
    dispatch(getFormData());
  }, [dispatch]);

  if (getHostIds().length === 0) {
    return (
      <Grid className="margin-40">
        <GridItem span={7}>
          <Alert
            variant="danger"
            title={__('No hosts with content source found!')}
          />
          { hostsWithoutContent.length > 0 && <IgnoredHostsAlert /> }
        </GridItem>
      </Grid>);
  }

  return (
    <Grid className="margin-40">
      <GridItem span={7}>
        <h1>{__('Change host content source')}</h1>

        { hostsWithoutContent.length > 0 && <IgnoredHostsAlert /> }
      </GridItem>

      <ContentSourceForm
        handleSubmit={handleSubmit}
        environments={environments}
        handleEnvironment={handleEnvironment}
        environmentId={environmentId}
        contentViews={contentViews}
        handleContentView={setContentViewId}
        contentViewId={contentViewId}
        contentSources={contentSources}
        contentSourceId={contentSourceId}
        handleContentSource={setContentSourceId}
        contentHostsIds={contentHostsIds}
        isLoading={isLoading}
      />
      { apiChangeStatus === STATUS.RESOLVED &&
      <ContentSourceTemplate template={template} jobInvocationPath={jobInvocationPath} /> }
    </Grid>
  );
};

export default ChangeContentSourcePage;
