import React, { useState } from 'react';
import { useSelector, shallowEqual } from 'react-redux';
import { Link } from 'react-router-dom';
import { Grid, GridItem, TextContent, Text, TextVariants, Button, Flex, FlexItem, Breadcrumb, BreadcrumbItem } from '@patternfly/react-core';
import Skeleton from 'react-loading-skeleton';
import { ExternalLinkAltIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';

import DetailsContainer from './DetailsContainer';
import ContentViewInfo from './ContentViewInfo';
import ContentViewVersions from './Versions/ContentViewVersions';
import ContentViewVersionDetails from './Versions/ContentViewVersionDetails';
import ContentViewRepositories from './Repositories/ContentViewRepositories';
import ContentViewComponents from './ComponentContentViews/ContentViewComponents';
import ContentViewHistories from './Histories/ContentViewHistories';
import ContentViewFilters from './Filters/ContentViewFilters';
import ContentViewFilterDetails from './Filters/ContentViewFilterDetails';
import { selectCVDetails } from './ContentViewDetailSelectors';
import RoutedTabs from '../../../components/RoutedTabs';
import ContentViewIcon from '../components/ContentViewIcon';
import PublishContentViewWizard from '../Publish/PublishContentViewWizard';

const ContentViewDetails = ({ match }) => {
  const cvId = parseInt(match.params.id, 10);
  const details = useSelector(state => selectCVDetails(state, cvId), shallowEqual);
  const [isPublishModalOpen, setIsPublishModalOpen] = useState(false);
  const [currentStep, setCurrentStep] = useState(1);

  const { name, composite } = details;
  const tabs = [
    {
      key: 'details',
      title: __('Details'),
      content: <ContentViewInfo {...{ cvId, details }} />,
    },
    {
      key: 'versions',
      title: __('Versions'),
      content: <ContentViewVersions cvId={cvId} />,
      detailContent: <ContentViewVersionDetails />,
    },
    (composite ? {
      key: 'contentviews',
      title: __('Content Views'),
      content: <ContentViewComponents {...{ cvId, details }} />,
    } : {
      key: 'repositories',
      title: __('Repositories'),
      content: <ContentViewRepositories {...{ cvId, details }} />,
    }
    ),
    {
      key: 'filters',
      title: __('Filters'),
      content: <ContentViewFilters cvId={cvId} />,
      detailContent: <ContentViewFilterDetails />,
    },
    {
      key: 'history',
      title: __('History'),
      content: <ContentViewHistories cvId={cvId} />,
    },
  ];

  return (
    <Grid className="grid-with-margin">
      <DetailsContainer cvId={cvId}>
        <React.Fragment>
          <Breadcrumb style={{ marginTop: '15px' }}>
            <BreadcrumbItem
              aria-label="cv_breadcrumb"
              render={() => (<Link to="/content_views" >{__('Content Views')}</Link>)}
            />
            <BreadcrumbItem aria-label="cv_breadcrumb_cv" isActive>
              {name || <Skeleton />}
            </BreadcrumbItem>
          </Breadcrumb>
          <GridItem xl={8} lg={7} sm={12} >
            <Flex>
              <FlexItem>
                <TextContent>
                  <Text component={TextVariants.h1}>{`${name} content view`}</Text>
                </TextContent>
              </FlexItem>
              <FlexItem spacer={{ default: 'spacerXl' }}>
                <Text component={TextVariants.h1}><ContentViewIcon composite={composite} /></Text>
              </FlexItem>
            </Flex>
          </GridItem>
          <GridItem xl={4} lg={5} sm={12} >
            <Flex justifyContent={{ lg: 'justifyContentFlexEnd', sm: 'justifyContentFlexStart' }}>
              <FlexItem>
                <Button onClick={() => { setIsPublishModalOpen(true); }} variant="primary" aria-label="publish_content_view">
                  Publish new version
                </Button>
                {isPublishModalOpen && <PublishContentViewWizard
                  details={details}
                  show={isPublishModalOpen}
                  setIsOpen={setIsPublishModalOpen}
                  currentStep={currentStep}
                  setCurrentStep={setCurrentStep}
                  aria-label="publish_content_view_modal"
                />}
              </FlexItem>
              <FlexItem>
                <Button
                  component="a"
                  aria-label="view tasks button"
                  href={`/foreman_tasks/tasks?search=resource_type%3D+Katello%3A%3AContentView+resource_id%3D${cvId}`}
                  target="_blank"
                  variant="secondary"
                >
                  {'View tasks '}
                  <ExternalLinkAltIcon />
                </Button>
              </FlexItem>
            </Flex>
          </GridItem>
          <GridItem span={12}>
            <RoutedTabs tabs={tabs} baseUrl={`/content_views/${cvId}`} defaultTabIndex={1} />
          </GridItem>
        </React.Fragment>
      </DetailsContainer>
    </Grid>
  );
};

ContentViewDetails.propTypes = {
  match: PropTypes.shape({
    params: PropTypes.shape({
      id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    }),
  }).isRequired,
};

export default ContentViewDetails;
