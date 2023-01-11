import React, { useState, useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';

import { Alert, Grid, GridItem, PageSection, Title } from '@patternfly/react-core';

import { translate as __ } from 'foremanReact/common/I18n';
import { foremanUrl } from 'foremanReact/common/helpers';
import { STATUS } from 'foremanReact/constants';
import BreadcrumbBar from 'foremanReact/components/BreadcrumbBar';
import Head from 'foremanReact/components/Head';

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

  const noHostSpecified = getHostIds(urlParams.host_id).length === 0 && urlParams.searchParam === '';

  const handleSubmit = (e) => {
    e.preventDefault();

    dispatch(changeContentSource(
      environmentId,
      contentViewId,
      contentSourceId,
      contentHosts.map(h => h.id),
      jobInvocationPath,
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

  const breadcrumbItems = () => {
    const linkHosts = { caption: __('Hosts'), url: foremanUrl('/hosts') };
    const linkContent = { caption: __('Change host content source') };

    if (urlParams.host_id) {
      const hostName = contentHosts.concat(hostsWithoutContent)
        .find(h => `${h.id}` === urlParams.host_id)?.name;

      return ([linkHosts, { caption: hostName, url: foremanUrl(`/new/hosts/${hostName}`) }, linkContent]);
    }
    return ([linkHosts, linkContent]);
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

  return (
    <>
      <Head>
        <title>{__('Change host content source')}</title>
      </Head>
      <PageSection
        isFilled
        variant="light"
      >
        <div className="margin-left-20">
          <BreadcrumbBar
            breadcrumbItems={breadcrumbItems()}
          />
        </div>
        <Grid className="margin-left-20">
          <GridItem span={7}>
            <Title
              headingLevel="h5"
              size="2xl"
            >
              {__('Change host content source')}
            </Title>
          </GridItem>
          {noHostSpecified &&
            <GridItem span={7}>
              <Alert
                variant="danger"
                className="margin-top-20"
                title={__('No hosts were specified')}
              />
            </GridItem>
        }
          { !noHostSpecified &&
          <>
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
              hostsUpdated={apiChangeStatus === STATUS.RESOLVED}
            />
          </> }
          { apiChangeStatus === STATUS.RESOLVED &&
          <ContentSourceTemplate template={template} jobInvocationPath={jobInvocationPath} /> }
        </Grid>
      </PageSection>
    </>
  );
};

export default ChangeContentSourcePage;
