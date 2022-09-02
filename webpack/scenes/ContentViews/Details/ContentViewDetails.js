import React, { useState, useEffect } from 'react';
import { useSelector, shallowEqual, useDispatch } from 'react-redux';
import { useParams } from 'react-router-dom';
import {
  Grid,
  GridItem,
  TextContent,
  Text,
  TextVariants,
  Button,
  Flex,
  FlexItem,
  Dropdown,
  DropdownItem,
  KebabToggle,
  DropdownPosition,
} from '@patternfly/react-core';
import { STATUS } from 'foremanReact/constants';
import { ExternalLinkAltIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';

import { selectIsPollingTask, selectIsPollingTaskComplete } from '../../Tasks/TaskSelectors';
import getContentViewDetails from './ContentViewDetailActions';
import Loading from '../../../components/Loading';
import ContentViewInfo from './ContentViewInfo';
import ContentViewVersionsRoutes from './Versions';
import ContentViewFilterRoutes from './Filters';
import ContentViewRepositories from './Repositories/ContentViewRepositories';
import ContentViewComponents from './ComponentContentViews/ContentViewComponents';
import ContentViewHistories from './Histories/ContentViewHistories';
import { selectCVDetails, selectCVDetailStatus, selectCVDetailError } from './ContentViewDetailSelectors';
import RoutedTabs from '../../../components/RoutedTabs';
import ContentViewIcon from '../components/ContentViewIcon';
import CVBreadCrumb from '../components/CVBreadCrumb';
import PublishContentViewWizard from '../Publish/PublishContentViewWizard';
import { hasPermission } from '../helpers';
import CopyContentViewModal from '../Copy/CopyContentViewModal';
import ContentViewDeleteWizard from '../Delete/ContentViewDeleteWizard';
import EmptyStateMessage from '../../../components/Table/EmptyStateMessage';
import { cvVersionTaskPollingKey } from '../ContentViewsConstants';
import { clearPollTaskData, stopPollingTask } from '../../Tasks/TaskActions';

export default () => {
  const { id } = useParams();
  const cvId = Number(id);
  const contentViewVersionTaskKey = cvVersionTaskPollingKey(cvId);
  const details = useSelector(state => selectCVDetails(state, cvId), shallowEqual);
  const [isPublishModalOpen, setIsPublishModalOpen] = useState(false);
  const [dropDownOpen, setDropdownOpen] = useState(false);
  const [copying, setCopying] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const dispatch = useDispatch();
  const status = useSelector(state => selectCVDetailStatus(state, cvId), shallowEqual);
  const error = useSelector(state => selectCVDetailError(state, cvId), shallowEqual);
  const taskNeedsToBeStopped = useSelector(state =>
    selectIsPollingTaskComplete(state, contentViewVersionTaskKey));
  const isTaskRunning = useSelector(state =>
    selectIsPollingTask(state, contentViewVersionTaskKey));

  useEffect(() => {
    if (taskNeedsToBeStopped) {
      dispatch(stopPollingTask(contentViewVersionTaskKey));
      dispatch(clearPollTaskData(contentViewVersionTaskKey));
    }
    return () => {
      // This stops the polling task if you leave contentView/XXX route.
      if (isTaskRunning && !taskNeedsToBeStopped) {
        dispatch(stopPollingTask(contentViewVersionTaskKey));
        dispatch(clearPollTaskData(contentViewVersionTaskKey));
      }
    };
  }, [contentViewVersionTaskKey, dispatch, isTaskRunning, taskNeedsToBeStopped]);

  useEffect(() => {
    dispatch(getContentViewDetails(cvId));
  }, [cvId, dispatch]);


  if (status === STATUS.PENDING) return (<Loading />);
  if (status === STATUS.ERROR) return (<EmptyStateMessage error={error} />);

  const dropDownItems = [
    <DropdownItem
      key="copy"
      onClick={() => {
        setCopying(true);
      }}
    >
      {__('Copy')}
    </DropdownItem>,
    <DropdownItem
      key="delete"
      onClick={() => {
        setDeleting(true);
      }}
    >
      {__('Delete')}
    </DropdownItem>,
  ];

  const {
    name, composite, permissions, environments, versions,
    generated_for: generatedFor, import_only: importOnly,
  } = details;
  const generatedContentView = generatedFor !== 'none';
  const tabs = [
    {
      key: 'details',
      title: __('Details'),
      content: <ContentViewInfo {...{ cvId, details }} />,
    },
    {
      key: 'versions',
      title: __('Versions'),
      content: <ContentViewVersionsRoutes {...{ cvId, details }} />,
    },
    ...composite ? [{
      key: 'contentviews',
      title: __('Content views'),
      content: <ContentViewComponents {...{ cvId, details }} />,
    }] : [{
      key: 'repositories',
      title: __('Repositories'),
      content: <ContentViewRepositories {...{ cvId, details }} />,
    },
    !(importOnly || generatedContentView) &&
    {
      key: 'filters',
      title: __('Filters'),
      content: <ContentViewFilterRoutes {...{ cvId, details }} />,
    }],
    {
      key: 'history',
      title: __('History'),
      content: <ContentViewHistories cvId={cvId} />,
    },
  ];


  return (
    <>
      <Grid>
        <Grid className="margin-16-24">
          <CVBreadCrumb />
          <GridItem md={8} sm={12}>
            <Flex alignItems={{
              default: 'alignItemsCenter',
            }}
            >
              <FlexItem>
                <TextContent>
                  <Text ouiaId="cv-details-header-name" component={TextVariants.h1}>
                    <ContentViewIcon count={name} composite={composite} />
                  </Text>
                </TextContent>
              </FlexItem>
            </Flex>
          </GridItem>
          <GridItem md={4} sm={12} style={{ minWidth: '380px' }}>
            <Flex justifyContent={{ lg: 'justifyContentFlexEnd', sm: 'justifyContentFlexStart' }}>
              {hasPermission(permissions, 'publish_content_views') &&
                <FlexItem>
                  <Button
                    ouiaId="cv-details-publish-button"
                    isDisabled={importOnly || generatedContentView}
                    onClick={() => setIsPublishModalOpen(true)}
                    variant="secondary"
                    aria-label="publish_content_view"
                  >
                    {__('Publish new version')}
                  </Button>
                  {isPublishModalOpen &&
                    <PublishContentViewWizard
                      details={details}
                      show={isPublishModalOpen}
                      onClose={(step3) => {
                        if (step3) dispatch(getContentViewDetails(cvId));
                        setIsPublishModalOpen(false);
                      }}
                      aria-label="publish_content_view_modal"
                    />}
                </FlexItem>
              }
              <FlexItem>
                <Button
                  ouiaId="cv-details-view-tasks-button"
                  component="a"
                  aria-label="view tasks button"
                  href={`/foreman_tasks/tasks?search=resource_type%3D+Katello%3A%3AContentView+resource_id%3D${cvId}`}
                  target="_blank"
                  variant="secondary"
                >
                  {__('View tasks ')}
                  <ExternalLinkAltIcon />
                </Button>
              </FlexItem>
              <FlexItem>
                <Dropdown
                  position={DropdownPosition.right}
                  style={{ marginLeft: 'auto' }}
                  toggle={<KebabToggle onToggle={setDropdownOpen} id="toggle-dropdown" />}
                  isOpen={dropDownOpen}
                  isPlain
                  dropdownItems={dropDownItems}
                />
              </FlexItem>
            </Flex>
          </GridItem>
        </Grid>
        <GridItem span={12}>
          <RoutedTabs tabs={tabs} defaultTabIndex={1} />
        </GridItem>
      </Grid>
      {
        copying &&
        <CopyContentViewModal
          cvId={cvId}
          cvName={name}
          show={copying}
          setIsOpen={setCopying}
          aria-label="copy_content_view_modal"
        />
      }
      {
        deleting &&
        <ContentViewDeleteWizard
          cvId={cvId && Number(cvId)}
          cvEnvironments={environments}
          cvVersions={versions}
          show={deleting}
          setIsOpen={setDeleting}
          aria-label="delete_content_view_modal"
        />
      }
    </>
  );
};
