import React, { useState, useEffect, useMemo } from 'react';
import { useSelector, useDispatch } from 'react-redux';

import { Alert, Grid, GridItem, PageSection, Title, Text, TextContent } from '@patternfly/react-core';

import { translate as __ } from 'foremanReact/common/I18n';
import { foremanUrl } from 'foremanReact/common/helpers';
import { STATUS } from 'foremanReact/constants';
import BreadcrumbBar from 'foremanReact/components/BreadcrumbBar';
import Head from 'foremanReact/components/Head';
import { useForemanHostsPageUrl } from 'foremanReact/Root/Context/ForemanContext';

import { selectApiDataStatus,
  selectApiContentViewStatus,
  selectApiChangeContentStatus,
  selectContentHosts,
  selectContentHostsWithoutContent,
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
  const contentSources = useSelector(selectContentSources);
  const jobInvocationPath = useSelector(selectJobInvocationPath);

  const template = useSelector(selectTemplate);
  const contentViews = useSelector(selectContentViews);

  const [contentSourceId, setCapsuleId] = useState('');
  const [selectedEnvironment, setSelectedEnvironment] = useState([]);
  const [contentViewName, setContentViewName] = useState('');
  const [shouldShowTemplate, setShouldShowTemplate] = useState(false);
  const [redirect, setRedirect] = useState(false);

  const contentViewId = contentViews?.find(cv => cv.name === contentViewName)?.id;
  const hostIds = useMemo(() => getHostIds(urlParams.host_id), [urlParams.host_id]);
  const noHostSpecified = (hostIds.length === 0 && urlParams.searchParam === '');
  const environmentId = selectedEnvironment[0]?.id;

  const redirectToJobInvocationForm = () => setRedirect(true);

  const handleSuccess = ({ shouldRedirect }) => {
    if (shouldRedirect) {
      redirectToJobInvocationForm();
    }
  };

  const handleSubmit = (e, { shouldRedirect = false }) => {
    e.preventDefault();

    dispatch(changeContentSource(
      environmentId,
      contentViewId,
      contentSourceId,
      contentHosts.map(h => h.id),
      () => handleSuccess({ shouldRedirect }),
    ));
  };

  const handleContentSource = (id) => {
    setCapsuleId(id);
    setSelectedEnvironment([]);
    setContentViewName('');

    if (id) {
      dispatch(getProxy(id));
    }
  };

  const showTemplate = (e) => {
    handleSubmit(e, { shouldRedirect: false });
    setShouldShowTemplate(true);
  };

  const hostIndexUrl = useForemanHostsPageUrl();
  const breadcrumbItems = () => {
    const linkHosts = { caption: __('Hosts'), url: hostIndexUrl };
    const linkContent = { caption: __('Change host content source') };

    if (urlParams.host_id) {
      const hostName = contentHosts.concat(hostsWithoutContent)
        .find(h => `${h.id}` === urlParams.host_id)?.name;
      return ([linkHosts, { caption: hostName, url: foremanUrl(`/new/hosts/${hostName}`) }, linkContent]);
    }
    return ([linkHosts, linkContent]);
  };

  const handleEnvironment = (selection) => {
    setSelectedEnvironment(selection);
    setContentViewName('');

    if (selection[0].id) {
      dispatch(getContentViews(selection[0].id));
    }
  };
  useEffect(() => {
    dispatch(getFormData(hostIds, urlParams.searchParam));
  }, [dispatch, hostIds, urlParams.searchParam]);

  if (redirect && jobInvocationPath) {
    window.location.assign(jobInvocationPath); // redirect to job invocation wizard
  }

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
              ouiaId="change-cs-title"
              headingLevel="h5"
              size="2xl"
              className="margin-top-20"
            >
              {__('Change host content source')}
            </Title>
            <TextContent>
              <Text ouiaId="change-content-source-description" id="ccs-description">
                {__('Changing a host\'s content source will change the Smart Proxy from which the host gets its content.')}
              </Text>
            </TextContent>
          </GridItem>
          {noHostSpecified &&
            <GridItem span={7}>
              <Alert
                ouiaId="no-host-alert"
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
              handleEnvironment={handleEnvironment}
              environments={selectedEnvironment}
              contentViews={contentViews}
              handleContentView={setContentViewName}
              contentViewName={contentViewName}
              contentSources={contentSources}
              contentSourceId={contentSourceId}
              handleContentSource={handleContentSource}
              contentHosts={contentHosts}
              isLoading={isLoading}
              hostsUpdated={apiChangeStatus === STATUS.RESOLVED || shouldShowTemplate}
              showTemplate={showTemplate}
            />
          </> }
          { (apiChangeStatus === STATUS.RESOLVED && shouldShowTemplate) &&
          <ContentSourceTemplate template={template} hostCount={contentHosts.length} /> }
        </Grid>
      </PageSection>
    </>
  );
};

export default ChangeContentSourcePage;
