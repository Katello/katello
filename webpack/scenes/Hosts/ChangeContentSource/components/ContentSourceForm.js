import React, { useState } from 'react';
import { FormattedMessage } from 'react-intl';
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
  Text,
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
import { selectContentViewsStatus, selectJobInvocationPath } from '../selectors';
import { getCVPlaceholderText, shouldDisableCVSelect } from '../../../ContentViews/components/ContentViewSelect/helpers';
import { selectEnvironmentPaths } from '../../../ContentViews/components/EnvironmentPaths/EnvironmentPathSelectors';

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
          value={cs.id}
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
  showCVOnlyAlert,
  hostDetailsPath,
  hostEditPath,
  contentHosts,
  isLoading,
  hostsUpdated,
  showTemplate,
}) => {
  const pathsUrl = `/organizations/${orgId()}/environments/paths?permission_type=promotable${contentSourceId ? `&content_source_id=${contentSourceId}` : ''}`;
  useAPI( // No TableWrapper here, so we can useAPI from Foreman
    'get',
    api.getApiUrl(pathsUrl),
    ENV_PATH_OPTIONS,
  );
  const contentViewsStatus = useSelector(selectContentViewsStatus);
  const environmentPathResponse = useSelector(selectEnvironmentPaths);
  const jobInvocationPath = useSelector(selectJobInvocationPath);
  const envList = environmentPathResponse?.results?.map(path => path.environments).flat();
  const [csSelectOpen, setCSSelectOpen] = useState(false);
  const [cvSelectOpen, setCVSelectOpen] = useState(false);
  const hostCount = contentHosts.length;

  const handleCSSelect = (_event, selection) => {
    handleContentSource(typeof selection === 'number' ? selection.toString() : selection);
    setCSSelectOpen(false);
  };

  const handleCVSelect = (_event, selection) => {
    handleContentView(selection);
    setCVSelectOpen(false);
  };

  const formIsValid = () => (!!environments &&
    !!contentViewName &&
    !!contentSourceId &&
    hostCount !== 0);
  const contentSourcesIsDisabled = (isLoading || contentSources.length === 0 ||
    hostCount === 0);
  const environmentIsDisabled = (isLoading ||
    contentSourceId === '');
  const viewIsDisabled = (isLoading || contentViews.length === 0 ||
    contentSourceId === '');

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
        {(hostCount === 0 && !isLoading) && (

        <GridItem span={7}>
          <Alert
            ouiaId="no-hosts-alert"
            variant="danger"
            className="margin-top-20"
            title={__('No hosts found')}
          />
        </GridItem>
        )}
        {contentViewsStatus === STATUS.RESOLVED &&
            !!environments.length && contentViews.length === 0 &&
            <Alert
              ouiaId="no-cv-alert"
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
      {envList?.some(env => env?.content_source?.environment_is_associated === false) &&
        <Alert
          ouiaId="disabled-environments-alert"
          variant="info"
          isInline
          title={__('Some environments are disabled because they are not associated with the selected content source.')}
          style={{ marginBottom: '1rem' }}
        >
          {__('To enable them, add the environment to the content source, or select a different content source.')}
        </Alert>
      }
      <EnvironmentPaths
        style={{ display: 'block' }}
        userCheckedItems={environments}
        setUserCheckedItems={handleEnvironment}
        publishing={false}
        multiSelect={false}
        headerText={__('Lifecycle environment')}
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
        {!environmentIsDisabled && contentViews?.map(cv => (<ContentViewSelectOption
          key={cv.id}
          value={cv.name}
          cv={cv}
          env={environments[0]}
        />))}
      </ContentViewSelect>
      {showCVOnlyAlert &&
        <Alert
          ouiaId="cv-only-alert"
          variant="info"
          className="margin-top-20"
          title={__('Host content source will remain the same. Click Save below to update the host\'s content view environment.')}
        />
      }
      {!showCVOnlyAlert &&
      <TextContent>
        <Text
          ouiaId="ccs-options-description"
        >
          <FormattedMessage
            defaultMessage={__('After configuring Foreman, configuration must also be updated on {hosts}. Choose one of the following options to update {hosts}:')}
            values={{
              hosts: (
                <FormattedMessage
                  defaultMessage="{count, plural, one {{singular}} other {# {plural}}}"
                  values={{
                    count: hostCount,
                    singular: __('the host'),
                    plural: __('hosts'),
                  }}
                  id="ccs-options-i18n"
                />
              ),
            }}
            id="ccs-options-description-i18n"
          />
        </Text>
      </TextContent>
      }
      <ActionGroup style={{ display: 'block' }}>
        {!showCVOnlyAlert &&
        <>
          <Button
            variant="primary"
            id="generate_btn"
            ouiaId="run-job-invocation-button"
            onClick={e => handleSubmit(e, { redirectTo: jobInvocationPath })}
            isDisabled={isLoading || !formIsValid() || hostsUpdated}
            isLoading={isLoading}
          >
            {__('Run job invocation')}
          </Button>
          <Button
            variant="secondary"
            id="generate_btn"
            ouiaId="update-source-button"
            onClick={showTemplate}
            isDisabled={isLoading || !formIsValid() || hostsUpdated}
            isLoading={isLoading}
          >
            {__('Update hosts manually')}
          </Button>
        </>
        }
        {showCVOnlyAlert &&
          <Button
            variant="primary"
            id="generate_btn"
            ouiaId="change-cv-button"
            onClick={e =>
              handleSubmit(e, {
                redirectTo: hostEditPath || hostDetailsPath,
                showSuccessToast: true,
              })
            }
            isDisabled={isLoading || !formIsValid() || hostsUpdated}
            isLoading={isLoading}
          >
            {__('Save')}
          </Button>
        }

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
  showCVOnlyAlert: PropTypes.bool,
  hostDetailsPath: PropTypes.string.isRequired,
  hostEditPath: PropTypes.string.isRequired,
  contentHosts: PropTypes.arrayOf(PropTypes.shape({})),
  isLoading: PropTypes.bool,
  hostsUpdated: PropTypes.bool,
  showTemplate: PropTypes.func.isRequired,
};

ContentSourceForm.defaultProps = {
  environments: [],
  contentViews: [],
  contentViewName: '',
  contentSources: [],
  contentSourceId: '',
  showCVOnlyAlert: false,
  contentHosts: [],
  isLoading: false,
  hostsUpdated: false,
};

export default ContentSourceForm;
