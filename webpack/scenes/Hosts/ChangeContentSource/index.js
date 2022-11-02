import React, { useState, useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';

import { Alert, Grid, GridItem } from '@patternfly/react-core';

import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';

import { selectApiDataStatus,
  selectApiContentViewStatus,
  selectApiChangeContentStatus,
  selectContentHosts,
  selectContentHostsWithoutContent,
  selectEnvironments,
  selectContentSources,
  selectJobInvocationPath,
  selectContentViews,
  selectTemplate } from './selectors';

import { getHostIds, formIsLoading } from './helpers';
import { useUrlParams } from '../../../components/Table/TableHooks';
import {
  getFormData,
  getProxy,
  changeContentSource,
  getContentViews,
} from './actions';
import ContentSourceForm from './components/ContentSourceForm';
import ContentSourceTemplate from './components/ContentSourceTemplate';
import Hosts from './components/Hosts';
import './styles.scss';

const ChangeContentSourcePage = () => {
  const dispatch = useDispatch();

  const urlParams = useUrlParams();
  const apiDataStatus = useSelector(selectApiDataStatus);
  const apiContentViewStatus = useSelector(selectApiContentViewStatus);
  const apiChangeStatus = useSelector(selectApiChangeContentStatus);

  const isLoading = formIsLoading(apiDataStatus, apiContentViewStatus, apiChangeStatus);

  const contentHosts = useSelector(selectContentHosts);
  const hostsWithoutContent = useSelector(selectContentHostsWithoutContent);
  const environments = useSelector(selectEnvironments);
  const contentSources = useSelector(selectContentSources);
  const jobInvocationPath = useSelector(selectJobInvocationPath);

  const template = useSelector(selectTemplate);
  const contentViews = useSelector(selectContentViews);

  const [contentSourceId, setCapsuleId] = useState('');
  const [environmentId, setEnvironmentId] = useState('');
  const [contentViewId, setContentViewId] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();

    dispatch(changeContentSource(
      environmentId,
      contentViewId,
      contentSourceId,
      contentHosts.map(h => h.id),
    ));
  };

  const handleContentSource = (id) => {
    setCapsuleId(id);
    setEnvironmentId('');
    setContentViewId('');

    if (id) {
      dispatch(getProxy(id));
    }
  };

  const handleEnvironment = (envId) => {
    setEnvironmentId(envId);
    setContentViewId('');

    if (envId) {
      dispatch(getContentViews(envId));
    }
  };
  useEffect(() => {
    dispatch(getFormData(getHostIds(urlParams.host_id), urlParams.searchParam));
  }, [dispatch, urlParams.host_id, urlParams.searchParam]);

  if (getHostIds(urlParams.host_id).length === 0 && urlParams.searchParam === '') {
    return (
      <Grid className="margin-40">
        <GridItem span={7}>
          <Alert
            variant="danger"
            title={__('No hosts with content source found!')}
          />
        </GridItem>
      </Grid>);
  }

  return (
    <Grid className="margin-40">
      <GridItem span={7}>
        <h1>{__('Change host content source')}</h1>
      </GridItem>
      <Hosts
        contentHosts={contentHosts}
        hostsWithoutContent={hostsWithoutContent}
      />

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
        handleContentSource={handleContentSource}
        contentHosts={contentHosts}
        isLoading={isLoading}
      />
      { apiChangeStatus === STATUS.RESOLVED &&
      <ContentSourceTemplate template={template} jobInvocationPath={jobInvocationPath} /> }
    </Grid>
  );
};

export default ChangeContentSourcePage;
