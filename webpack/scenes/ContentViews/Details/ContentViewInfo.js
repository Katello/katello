import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import {
  Button,
  Flex,
  FlexItem,
  TextContent,
  TextList,
  TextListVariants,
  TextListItem,
  TextListItemVariants,
  Switch,
} from '@patternfly/react-core';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';

import { updateContentView } from './ContentViewDetailActions';
import { selectIsCVUpdating } from './ContentViewDetailSelectors';
import ContentViewIcon from '../components/ContentViewIcon';
import ActionableDetail from '../../../components/ActionableDetail';
import './contentViewInfo.scss';
import { dependenciesHelpText, autoPublishHelpText, hasPermission } from '../helpers';
import { LabelImportOnly, LabelGenerated } from '../Create/ContentViewFormComponents';
import getEnvironmentPaths from '../components/EnvironmentPaths/EnvironmentPathActions';
import EnvironmentPaths from '../components/EnvironmentPaths/EnvironmentPaths';

const ContentViewInfo = ({ cvId, details }) => {
  const dispatch = useDispatch();
  const [currentAttribute, setCurrentAttribute] = useState();
  const updating = useSelector(state => selectIsCVUpdating(state));
  const {
    name,
    label,
    description,
    composite,
    rolling,
    solve_dependencies: solveDependencies,
    auto_publish: autoPublish,
    import_only: importOnly,
    generated_for: generatedFor,
    environments,
    permissions,
  } = details;
  const [selectedEnvs, setSelectedEnvs] = useState([]);
  const [buttonLoading, setButtonLoading] = useState(false);
  const generatedContentView = generatedFor !== 'none';
  const onEdit = (val, attribute) => {
    if (val === details[attribute]) return;
    dispatch(updateContentView(cvId, { [attribute]: val }));
  };
  let iconText = __('Content view');
  if (composite) { iconText = __('Composite content view'); } else if (rolling) { iconText = __('Rolling content view'); }
  useEffect(
    () => {
      if (rolling) {
        dispatch(getEnvironmentPaths());
      }
    },
    [rolling, dispatch],
  );
  // Fetch environment paths only if rolling content view
  useEffect(() => {
    if (environments?.length) {
      setSelectedEnvs(environments);
    }
  }, [environments, setSelectedEnvs]);


  const updateEnvs = (optedEnvs) => {
    setButtonLoading(true);
    const checkedEnvIds = optedEnvs?.map(env => env.id) ?? [];
    dispatch(updateContentView(cvId, { environment_ids: checkedEnvIds }, () => {
    // This callback runs only on success
      setButtonLoading(false);
    }));
  };
  return (
    <TextContent className="margin-0-24">
      <TextList component={TextListVariants.dl}>
        <ActionableDetail
          key={name}
          label={__('Name')}
          attribute="name"
          loading={updating && currentAttribute === 'name'}
          onEdit={onEdit}
          disabled={!hasPermission(permissions, 'edit_content_views')}
          value={name}
          {...{ currentAttribute, setCurrentAttribute }}
        />
        <TextListItem component={TextListItemVariants.dt}>
          {__('Label')}
        </TextListItem>
        <TextListItem
          aria-label="label text value"
          component={TextListItemVariants.dd}
          className="foreman-spaced-list"
        >
          {label}
        </TextListItem>
        <TextListItem component={TextListItemVariants.dt}>
          {__('Type')}
        </TextListItem>
        <TextListItem component={TextListItemVariants.dd} className="foreman-spaced-list">
          <Flex>
            <FlexItem spacer={{ default: 'spacerXs' }}>
              <ContentViewIcon composite={composite} rolling={rolling} description={iconText} />
            </FlexItem>
          </Flex>
        </TextListItem>
        <ActionableDetail
          key={description}
          textArea
          label={__('Description')}
          attribute="description"
          loading={updating && currentAttribute === 'description'}
          onEdit={onEdit}
          disabled={!hasPermission(permissions, 'edit_content_views')}
          value={description}
          {...{ currentAttribute, setCurrentAttribute }}
        />
        {composite ?
          (<ActionableDetail
            key={autoPublish}
            label={__('Autopublish')}
            attribute="auto_publish"
            loading={updating && currentAttribute === 'auto_publish'}
            value={autoPublish}
            onEdit={onEdit}
            disabled={!hasPermission(permissions, 'edit_content_views')}
            tooltip={autoPublishHelpText}
            boolean
            {...{ currentAttribute, setCurrentAttribute }}
          />) :
          (!rolling && <ActionableDetail
            label={__('Solve dependencies')}
            attribute="solve_dependencies"
            key={solveDependencies}
            loading={updating && currentAttribute === 'solve_dependencies'}
            value={solveDependencies}
            onEdit={onEdit}
            disabled={!hasPermission(permissions, 'edit_content_views')}
            tooltip={dependenciesHelpText}
            boolean
            {...{ currentAttribute, setCurrentAttribute }}
          />)}
        {importOnly &&
          <>
            <TextListItem component={TextListItemVariants.dt}>
              {LabelImportOnly()}
            </TextListItem>
            <TextListItem component={TextListItemVariants.dd} className="foreman-spaced-list">
              <Switch
                id="import_only_switch"
                ouiaId="import_only_switch"
                aria-label="import_only_switch"
                isChecked={importOnly}
                className="foreman-spaced-list"
                disabled
              />
            </TextListItem>
          </>}
        {generatedContentView &&
          <>
            <TextListItem component={TextListItemVariants.dt}>
              {LabelGenerated()}
            </TextListItem>
            <TextListItem component={TextListItemVariants.dd} className="foreman-spaced-list">
              <Switch
                id="generated_by_export_switch"
                ouiaId="generated_by_export_switch"
                aria-label="generated_by_export_switch"
                isChecked={generatedContentView}
                className="foreman-spaced-list"
                disabled
              />
            </TextListItem>
          </>}
        {rolling &&
          <>
            <TextListItem component={TextListItemVariants.dt}>
              {__('Lifecycle Environments')}
            </TextListItem>
            <TextListItem component={TextListItemVariants.dd} className="foreman-spaced-list">
              <EnvironmentPaths
                headerText=""
                publishing={false}
                userCheckedItems={selectedEnvs}
                setUserCheckedItems={setSelectedEnvs}
              />
              <Flex>
                <FlexItem spacer={{ default: 'spacerXs' }}>
                  <Button
                    ouiaId="save-button"
                    isLoading={buttonLoading}
                    isDisabled={buttonLoading}
                    onClick={() => updateEnvs(selectedEnvs)}
                    style={{ marginTop: '1rem' }}
                  >
                    {__('Save Environments')}
                  </Button>
                </FlexItem>
              </Flex>
            </TextListItem>
          </>
         }
      </TextList>
    </TextContent>
  );
};

ContentViewInfo.propTypes = {
  cvId: PropTypes.number.isRequired,
  details: PropTypes.shape({
    name: PropTypes.string,
    label: PropTypes.string,
    description: PropTypes.string,
    composite: PropTypes.bool,
    rolling: PropTypes.bool,
    solve_dependencies: PropTypes.bool,
    auto_publish: PropTypes.bool,
    import_only: PropTypes.bool,
    generated_for: PropTypes.string,
    environments: PropTypes.arrayOf(PropTypes.shape({})),
    permissions: PropTypes.shape({}),
  }).isRequired,
};

export default ContentViewInfo;
