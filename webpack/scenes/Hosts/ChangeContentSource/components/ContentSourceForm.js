import React, { useState } from 'react';
import {
  ActionGroup,
  Alert,
  Button,
  Form,
  Grid,
  GridItem,
  Select,
  SelectOption,
  SelectVariant,
  TextContent,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';
import api, { orgId } from '../../../../services/api';
import { ENVIRONMENT_PATHS_KEY } from '../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPathConstants';
import EnvironmentPaths from '../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPaths';
import ContentViewSelect from '../../../../scenes/ContentViews/components/ContentViewSelect/ContentViewSelect';
import ContentViewSelectOption from '../../../../scenes/ContentViews/components/ContentViewSelect/ContentViewSelectOption';

const ENV_PATH_OPTIONS = { key: ENVIRONMENT_PATHS_KEY };

const ContentSourceSelect = ({
  contentSources,
  selections,
  onToggle,
  onSelect,
  isOpen,
  isDisabled,
}) => (
  <div className="content_source_section">
    <TextContent>{__('Content source')}</TextContent>
    <Select
      variant={SelectVariant.single}
      aria-label="content-source-select"
      ouiaId="content-source-select"
      onToggle={onToggle}
      onSelect={onSelect}
      selections={selections}
      isOpen={isOpen}
      isDisabled={isDisabled}
      className="set-select-width"
    >
      {contentSources.map(cs => (
        <SelectOption
          key={cs.id}
          value={`${cs.id}`}
        >
          {cs.name}
        </SelectOption>
      ))}
    </Select>
  </div>
);

ContentSourceSelect.propTypes = {
  contentSources: PropTypes.arrayOf(PropTypes.shape({})),
  selections: PropTypes.string,
  onToggle: PropTypes.func,
  onSelect: PropTypes.func,
  isOpen: PropTypes.bool,
  isDisabled: PropTypes.bool,
};

ContentSourceSelect.defaultProps = {
  contentSources: [],
  selections: null,
  onToggle: undefined,
  onSelect: undefined,
  isOpen: false,
  isDisabled: false,
};

const ContentSourceForm = ({
  handleSubmit,
  environments,
  handleEnvironment,
  contentViews,
  handleContentView,
  contentViewId,
  contentSources,
  handleContentSource,
  contentSourceId,
  contentHosts,
  isLoading,
  hostsUpdated,
}) => {
  useAPI( // No TableWrapper here, so we can useAPI from Foreman
    'get',
    api.getApiUrl(`/organizations/${orgId()}/environments/paths?permission_type=promotable`),
    ENV_PATH_OPTIONS,
  );

  const [csSelectOpen, setCSSelectOpen] = useState(false);
  const [cvSelectOpen, setCVSelectOpen] = useState(false);

  const handleCSSelect = (_event, selection) => {
    handleContentSource(selection);
    setCSSelectOpen(false);
  };

  const handleCVSelect = (_event, selection) => {
    handleContentView(selection);
    setCVSelectOpen(false);
  };

  const formIsValid = () => (!!environments &&
    !!contentViewId &&
    !!contentSourceId &&
    contentHosts.length !== 0);

  const contentSourcesIsDisabled = (isLoading || contentSources.length === 0 ||
    contentHosts.length === 0);
  const environmentIsDisabled = (isLoading || environments === [] ||
    contentSourceId === '');
  const viewIsDisabled = (isLoading || contentViews.length === 0 ||
    contentSourceId === '' || environments === []);

  return (
    <Form
      onSubmit={e => handleSubmit(e)}
      className="content_source_form"
      isHorizontal
    >
      <Grid hasGutter className="margin-top-16">
        {(contentHosts.length === 0 && !isLoading) && (

        <GridItem span={7}>
          <Alert
            variant="danger"
            className="margin-top-20"
            title={__('No hosts found')}
          />
        </GridItem>
        )}
        <ContentSourceSelect
          contentSources={contentSources}
          selections={contentSourceId}
          onToggle={isExpanded => setCSSelectOpen(isExpanded)}
          onSelect={handleCSSelect}
          onClear={() => handleContentSource(null)}
          isOpen={csSelectOpen}
          isDisabled={contentSourcesIsDisabled}
        />
        <EnvironmentPaths
          userCheckedItems={environments}
          setUserCheckedItems={handleEnvironment}
          publishing={false}
          multiSelect={false}
          headerText={__('Environment')}
          isDisabled={environmentIsDisabled}
        />
        {environments.length > 0 &&
        <ContentViewSelect
          selections={contentViewId}
          onClear={() => handleContentView(null)}
          onSelect={handleCVSelect}
          isOpen={cvSelectOpen}
          isDisabled={viewIsDisabled}
          onToggle={isExpanded => setCVSelectOpen(isExpanded)}
          headerText={(contentViews.length === 0) ? __('No content views available') : __('Content view')}
          ouiaId="SelectContentView"
          className="set-select-width"
        >
          {contentViews?.map(cv => ContentViewSelectOption(cv, environments[0]))}
        </ContentViewSelect>
        }

        <GridItem>
          <ActionGroup>
            <Button
              variant="primary"
              id="generate_btn"
              onClick={e => handleSubmit(e)}
              isDisabled={isLoading || !formIsValid() || hostsUpdated}
              isLoading={isLoading}
            >
              {__('Update')}
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
  contentViews: PropTypes.arrayOf(PropTypes.shape({})),
  handleContentView: PropTypes.func.isRequired,
  contentViewId: PropTypes.string,
  contentSources: PropTypes.arrayOf(PropTypes.shape({})),
  handleContentSource: PropTypes.func.isRequired,
  contentSourceId: PropTypes.string,
  contentHosts: PropTypes.arrayOf(PropTypes.shape({})),
  isLoading: PropTypes.bool,
  hostsUpdated: PropTypes.bool,
};

ContentSourceForm.defaultProps = {
  environments: [],
  contentViews: [],
  contentViewId: '',
  contentSources: [],
  contentSourceId: '',
  contentHosts: [],
  isLoading: false,
  hostsUpdated: false,
};

export default ContentSourceForm;
