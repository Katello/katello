import React from 'react';
import {
  ActionGroup,
  Button,
  Form,
  Grid,
  GridItem,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';

import FormField from './FormField';

const ContentSourceForm = ({
  handleSubmit,
  environments,
  handleEnvironment,
  environmentId,
  contentViews,
  handleContentView,
  contentViewId,
  contentSources,
  handleContentSource,
  contentSourceId,
  contentHostsIds,
  isLoading,
}) => {
  const formIsValid = () => (!!environmentId &&
    !!contentViewId &&
    !!contentSourceId &&
    contentHostsIds.length !== 0);

  return (
    <Form
      onSubmit={e => handleSubmit(e)}
      className="content_source_form"
      isHorizontal
    >
      <Grid hasGutter>
        <FormField label={__('Environment')} id="change_cs_environment" value={environmentId} items={environments} onChange={handleEnvironment} isLoading={isLoading} contentHostsCount={contentHostsIds.length} />
        <FormField label={__('Content View')} id="change_cs_content_view" value={contentViewId} items={contentViews} onChange={handleContentView} isLoading={isLoading} contentHostsCount={contentHostsIds.length} />
        <FormField label={__('Content Source')} id="change_cs_content_source" value={contentSourceId} items={contentSources} onChange={handleContentSource} isLoading={isLoading} contentHostsCount={contentHostsIds.length} />

        <GridItem>
          <ActionGroup>
            <Button
              variant="primary"
              id="generate_btn"
              onClick={e => handleSubmit(e)}
              isDisabled={isLoading || !formIsValid()}
              isLoading={isLoading}
            >
              {__('Change content source')}
            </Button>
          </ActionGroup>
        </GridItem>
      </Grid>
    </Form>);
};

ContentSourceForm.propTypes = {
  handleSubmit: PropTypes.func.isRequired,
  environments: PropTypes.arrayOf(PropTypes.shape({})),
  handleEnvironment: PropTypes.func.isRequired,
  environmentId: PropTypes.string,
  contentViews: PropTypes.arrayOf(PropTypes.shape({})),
  handleContentView: PropTypes.func.isRequired,
  contentViewId: PropTypes.string,
  contentSources: PropTypes.arrayOf(PropTypes.shape({})),
  handleContentSource: PropTypes.func.isRequired,
  contentSourceId: PropTypes.string,
  contentHostsIds: PropTypes.arrayOf(PropTypes.number),
  isLoading: PropTypes.bool,
};

ContentSourceForm.defaultProps = {
  environments: [],
  environmentId: '',
  contentViews: [],
  contentViewId: '',
  contentSources: [],
  contentSourceId: '',
  contentHostsIds: [],
  isLoading: false,
};

export default ContentSourceForm;
