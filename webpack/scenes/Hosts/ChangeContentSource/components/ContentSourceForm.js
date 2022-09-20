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
  contentHosts,
  isLoading,
}) => {
  const formIsValid = () => (!!environmentId &&
    !!contentViewId &&
    !!contentSourceId &&
    contentHosts.length !== 0);

  const contentSourcesIsDisabled = (isLoading || contentSources.length === 0 ||
    contentHosts.length === 0);
  const environmentIsDisabled = (isLoading || environments.length === 0 ||
    contentSourceId === '');
  const viewIsDisabled = (isLoading || contentViews.length === 0 ||
    contentSourceId === '' || environmentId === '');

  return (
    <Form
      onSubmit={e => handleSubmit(e)}
      className="content_source_form"
      isHorizontal
    >
      <Grid hasGutter className="margin-top-16">
        <FormField label={__('Content source')} id="change_cs_content_source" value={contentSourceId} items={contentSources} onChange={handleContentSource} isDisabled={contentSourcesIsDisabled} />
        <FormField label={__('Environment')} id="change_cs_environment" value={environmentId} items={environments} onChange={handleEnvironment} isDisabled={environmentIsDisabled} />
        <FormField label={__('Content view')} id="change_cs_content_view" value={contentViewId} items={contentViews} onChange={handleContentView} isDisabled={viewIsDisabled} />

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
  contentHosts: PropTypes.arrayOf(PropTypes.shape({})),
  isLoading: PropTypes.bool,
};

ContentSourceForm.defaultProps = {
  environments: [],
  environmentId: '',
  contentViews: [],
  contentViewId: '',
  contentSources: [],
  contentSourceId: '',
  contentHosts: [],
  isLoading: false,
};

export default ContentSourceForm;
