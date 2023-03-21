import React, { useState } from 'react';
import { useSelector } from 'react-redux';
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
import { STATUS } from 'foremanReact/constants';
import api, { orgId } from '../../../../services/api';
import { ENVIRONMENT_PATHS_KEY } from '../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPathConstants';
import EnvironmentPaths from '../../../../scenes/ContentViews/components/EnvironmentPaths/EnvironmentPaths';
import ContentViewSelect from '../../../../scenes/ContentViews/components/ContentViewSelect/ContentViewSelect';
import ContentViewSelectOption from '../../../../scenes/ContentViews/components/ContentViewSelect/ContentViewSelectOption';
import { selectContentViewsStatus } from '../selectors';
import { getCVPlaceholderText, shouldDisableCVSelect } from '../../../ContentViews/components/ContentViewSelect/helpers';

const ENV_PATH_OPTIONS = { key: ENVIRONMENT_PATHS_KEY };

const ContentSourceSelect = ({
  contentSources,
  selections,
  onToggle,
  onSelect,
  isOpen,
  isDisabled,
  onClear,
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
      onClear={onClear}
      className="set-select-width"
      placeholderText={__('Select a source')}
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
  onClear: PropTypes.func,
  isOpen: PropTypes.bool,
  isDisabled: PropTypes.bool,
};

ContentSourceSelect.defaultProps = {
  contentSources: [],
  selections: null,
  onToggle: undefined,
  onSelect: undefined,
  onClear: undefined,
  isOpen: false,
  isDisabled: false,
};

const ContentSourceForm = ({
  handleSubmit,
  environments,
  handleEnvironment,
  contentViews,
  handleContentView,
  contentViewName,
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
  const contentViewsStatus = useSelector(selectContentViewsStatus);
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
    !!contentViewName &&
    !!contentSourceId &&
    contentHosts.length !== 0);

  const contentSourcesIsDisabled = (isLoading || contentSources.length === 0 ||
    contentHosts.length === 0);
  const environmentIsDisabled = (isLoading || environments === [] ||
    contentSourceId === '');
  const viewIsDisabled = (isLoading || contentViews.length === 0 ||
    contentSourceId === '' || environments === []);

  const cvPlaceholderText = getCVPlaceholderText({
    contentSourceId,
    environments,
    contentViewsStatus,
    cvSelectOptions: contentViews,
  });

  const disableCVSelect = shouldDisableCVSelect({
    contentSourceId,
    environments,
    contentViewsStatus,
    cvSelectOptions: contentViews,
  });

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
        {contentViewsStatus === STATUS.RESOLVED &&
            !!environments.length && contentViews.length === 0 &&
            <Alert
              variant="warning"
              className="margin-top-20"
              title={__('No content views available for the selected environment')}
              style={{ marginBottom: '1rem' }}
            >
              <a href="/content_views">{__('View the Content Views page')}</a>
              {__(' to manage and promote content views, or select a different environment.')}
            </Alert>
        }
      </Grid>
      <ContentSourceSelect
        contentSources={contentSources}
        selections={contentSourceId}
        onToggle={isExpanded => setCSSelectOpen(isExpanded)}
        onSelect={handleCSSelect}
        onClear={() => handleContentSource(null)}
        isOpen={csSelectOpen}
        isDisabled={contentSourcesIsDisabled || hostsUpdated}
      />
      <EnvironmentPaths
        style={{ display: 'block' }}
        userCheckedItems={environments}
        setUserCheckedItems={handleEnvironment}
        publishing={false}
        multiSelect={false}
        headerText={__('Environment')}
        isDisabled={environmentIsDisabled || hostsUpdated}
      />
      <ContentViewSelect
        selections={contentViewName}
        onClear={() => handleContentView(null)}
        onSelect={handleCVSelect}
        isOpen={cvSelectOpen}
        isDisabled={viewIsDisabled || hostsUpdated || disableCVSelect}
        onToggle={isExpanded => setCVSelectOpen(isExpanded)}
        headerText={__('Content view')}
        ouiaId="SelectContentView"
        className="set-select-width"
        placeholderText={cvPlaceholderText}
      >
        {!environmentIsDisabled && contentViews?.map(cv => <ContentViewSelectOption key={`${cv.id}`} cv={cv} env={environments[0]} />)}
      </ContentViewSelect>
      <ActionGroup style={{ display: 'block' }}>
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
    </Form>);
};

ContentSourceForm.propTypes = {
  handleSubmit: PropTypes.func.isRequired,
  environments: PropTypes.arrayOf(PropTypes.shape({})),
  handleEnvironment: PropTypes.func.isRequired,
  contentViews: PropTypes.arrayOf(PropTypes.shape({})),
  handleContentView: PropTypes.func.isRequired,
  contentViewName: PropTypes.string,
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
  contentViewName: '',
  contentSources: [],
  contentSourceId: '',
  contentHosts: [],
  isLoading: false,
  hostsUpdated: false,
};

export default ContentSourceForm;
