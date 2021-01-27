import React from 'react';
import { useSelector, shallowEqual } from 'react-redux';
import { Grid, GridItem, TextContent, Text, TextVariants, Button } from '@patternfly/react-core';
import { ExternalLinkAltIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';

import DetailsContainer from './DetailsContainer';
import ContentViewInfo from './ContentViewInfo';
import ContentViewRepositories from './Repositories/ContentViewRepositories';
import ContentViewFilters from './Filters/ContentViewFilters';
import ContentViewFilterDetails from './Filters/ContentViewFilterDetails';
import { selectCVDetails } from './ContentViewDetailSelectors';
import RoutedTabs from '../../../components/RoutedTabs';

const ContentViewDetails = ({ match }) => {
  const cvId = parseInt(match.params.id, 10);
  const details = useSelector(state => selectCVDetails(state, cvId), shallowEqual);

  const { name } = details;
  const tabs = [
    {
      key: 'details',
      title: __('Details'),
      content: <ContentViewInfo {...{ cvId, details }} />,
    },
    {
      key: 'versions',
      title: __('Versions'),
      content: <React.Fragment>Versions</React.Fragment>,
    },
    {
      key: 'repositories',
      title: __('Repositories'),
      content: <ContentViewRepositories {...{ cvId, details }} />,
    },
    {
      key: 'filters',
      title: __('Filters'),
      content: <ContentViewFilters cvId={cvId} />,
      detailContent: <ContentViewFilterDetails />,
    },
    {
      key: 'history',
      title: __('History'),
      content: <React.Fragment>History</React.Fragment>,
    },
  ];

  return (
    <Grid className="grid-with-margin">
      <DetailsContainer cvId={cvId}>
        <React.Fragment>
          <GridItem span={8}>
            <TextContent>
              <Text component={TextVariants.h1}>{`${name} content view`}</Text>
            </TextContent>
          </GridItem>
          <GridItem span={4} style={{ textAlign: 'right' }}>
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
          </GridItem>
          <GridItem span={12}>
            <RoutedTabs tabs={tabs} baseUrl={`/labs/content_views/${cvId}`} defaultTabIndex={1} />
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
