import React from 'react';
import { useSelector, shallowEqual } from 'react-redux';
import { Grid, GridItem, TextContent, Text, TextVariants } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';

import DetailsContainer from './DetailsContainer';
import ContentViewInfo from './ContentViewInfo';
import { selectCVDetails } from './ContentViewDetailSelectors';
import TabbedView from '../../../components/TabbedView/TabbedView';

const ContentViewDetails = ({ match }) => {
  const cvId = parseInt(match.params.id, 10);
  const details = useSelector(state => selectCVDetails(state, cvId), shallowEqual);
  const {
    name,
    label,
    description,
    composite,
    force_puppet_environment: forcePuppetEnvironment,
    solve_dependencies: solveDependencies,
  } = details;
  const info = {
    name: {
      value: name,
      label: __('Name'),
    },
    label: {
      value: label,
      label: __('Label'),
      editable: false,
    },
    description: {
      value: description,
      label: __('Description'),
      textArea: true,
    },
    composite: {
      value: composite,
      label: __('Composite'),
      boolean: true,
      editable: false,
    },
    force_puppet_environment: {
      value: forcePuppetEnvironment,
      label: __('Force Puppet environment'),
      boolean: true,
      tooltip: __('With this option selected, a puppet environment will be created during publish ' +
               'and promote even if no puppet modules have been added to the Content View'),
    },
    solve_dependencies: {
      value: solveDependencies,
      label: __('Solve dependencies'),
      boolean: true,
      tooltip: __('This option will solve RPM and Module Stream dependencies on every publish of ' +
               'this Content View. Dependency solving significantly increases publish time ' +
               '(publishes can take over three times as long) and filters will be ignored when ' +
               'adding packages to solve dependencies. Also, certain scenarios involving errata ' +
               'may still cause dependency errors.'),
    },
  };

  const tabs = [
    {
      title: __('Details'),
      content: <ContentViewInfo {...{ info, cvId }} />,
    },
    {
      title: __('Versions'),
      content: <React.Fragment>Versions</React.Fragment>,
    },
    {
      title: __('Repositories'),
      content: <React.Fragment>Repositories</React.Fragment>,
    },
    {
      title: __('Filters'),
      content: <React.Fragment>Filters</React.Fragment>,
    },
    {
      title: __('History'),
      content: <React.Fragment>History</React.Fragment>,
    },
    {
      title: __('Tasks'),
      content: <React.Fragment>Tasks</React.Fragment>,
    },
  ];

  return (
    <Grid className="grid-with-margin">
      <DetailsContainer cvId={cvId}>
        <React.Fragment>
          <GridItem span={12}>
            <TextContent>
              <Text component={TextVariants.h1}>{`${name} content view`}</Text>
            </TextContent>
          </GridItem>
          <GridItem span={12}>
            <TabbedView tabs={tabs} />
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
