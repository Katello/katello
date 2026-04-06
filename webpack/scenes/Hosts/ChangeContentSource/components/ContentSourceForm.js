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
  TextContent,
  Text,
} from '@patternfly/react-core';
import {
  Select,
  SelectOption,
  SelectVariant,
} from '@patternfly/react-core/deprecated';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';
import { selectJobInvocationPath } from '../selectors';
import MultiCVEnvForm from './MultiCVEnvForm';

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
  allowMultipleContentViews,
  assignments,
  onAssignmentsChange,
  organizationId,
}) => {
  const jobInvocationPath = useSelector(selectJobInvocationPath);
  const [csSelectOpen, setCSSelectOpen] = useState(false);
  const hostCount = contentHosts.length;

  const handleCSSelect = (_event, selection) => {
    handleContentSource(typeof selection === 'number' ? selection.toString() : selection);
    setCSSelectOpen(false);
  };

  const formIsValid = () => (
    !!contentSourceId &&
    assignments.length > 0 &&
    assignments.every(a => a.contentView && a.selectedEnv?.length > 0) &&
    hostCount !== 0
  );
  const contentSourcesIsDisabled = (isLoading || contentSources.length === 0 ||
    hostCount === 0);

  const isAssignmentComplete = a => a.contentView && a.selectedEnv?.length > 0;
  const completeAssignmentCount = assignments.filter(isAssignmentComplete).length;

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
      </Grid>
      <ContentSourceSelect
        contentSources={contentSources}
        selections={contentSourceId}
        onToggle={isExpanded => setCSSelectOpen(!!isExpanded)}
        onSelect={handleCSSelect}
        onClear={() => handleContentSource(null)}
        isOpen={!!csSelectOpen}
        isDisabled={contentSourcesIsDisabled || hostsUpdated}
      />
      {contentSourceId && (
        <MultiCVEnvForm
          organizationId={organizationId}
          contentSourceId={contentSourceId}
          assignmentCount={completeAssignmentCount}
          onAssignmentsChange={onAssignmentsChange}
          allowMultipleContentViews={allowMultipleContentViews}
          isLoading={isLoading || hostsUpdated}
        />
      )}
      {showCVOnlyAlert &&
        <Alert
          ouiaId="cv-only-alert"
          variant="info"
          className="margin-top-20"
          title={__('Host content source will remain the same. Click Save below to update the host\'s content view environments.')}
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
  allowMultipleContentViews: PropTypes.bool,
  assignments: PropTypes.arrayOf(PropTypes.shape({})),
  onAssignmentsChange: PropTypes.func.isRequired,
  organizationId: PropTypes.number,
};

ContentSourceForm.defaultProps = {
  contentSources: [],
  contentSourceId: '',
  showCVOnlyAlert: false,
  contentHosts: [],
  isLoading: false,
  hostsUpdated: false,
  allowMultipleContentViews: false,
  assignments: [],
  organizationId: null,
};

export default ContentSourceForm;
