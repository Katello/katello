import React, { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import {
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
import Loading from '../../../components/Loading';
import ContentViewIcon from '../components/ContentViewIcon';
import ActionableDetail from '../../../components/ActionableDetail';
import './contentViewInfo.scss';
import { dependenciesHelpText, autoPublishHelpText, hasPermission } from '../helpers';
import { LabelImportOnly } from '../Create/ContentViewFormComponents';

const ContentViewInfo = ({ cvId, details }) => {
  const dispatch = useDispatch();
  const [currentAttribute, setCurrentAttribute] = useState();
  const updating = useSelector(state => selectIsCVUpdating(state));
  const {
    name,
    label,
    description,
    composite,
    solve_dependencies: solveDependencies,
    auto_publish: autoPublish,
    import_only: importOnly,
    permissions,
  } = details;

  if (updating) return <Loading size="sm" showText={false} />;

  const onEdit = (val, attribute) => {
    if (val === details[attribute]) return;
    dispatch(updateContentView(cvId, { [attribute]: val }));
  };

  // Guarantees strings update despite render chain
  const uniqueKey = name + label + description;

  return (
    <TextContent className="margin-0-24">
      <TextList key={uniqueKey} component={TextListVariants.dl}>
        <ActionableDetail
          label={__('Name')}
          attribute="name"
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
              <ContentViewIcon composite={composite} description={composite ? __('Composite') : __('Component')} />
            </FlexItem>
          </Flex>
        </TextListItem>
        <ActionableDetail
          textArea
          label={__('Description')}
          attribute="description"
          onEdit={onEdit}
          disabled={!hasPermission(permissions, 'edit_content_views')}
          value={description}
          {...{ currentAttribute, setCurrentAttribute }}
        />
        {composite ?
          (<ActionableDetail
            label={__('Autopublish')}
            attribute="auto_publish"
            value={autoPublish}
            onEdit={onEdit}
            disabled={!hasPermission(permissions, 'edit_content_views')}
            tooltip={autoPublishHelpText}
            boolean
            {...{ currentAttribute, setCurrentAttribute }}
          />) :
          (<ActionableDetail
            label={__('Solve dependencies')}
            attribute="solve_dependencies"
            value={solveDependencies}
            onEdit={onEdit}
            disabled={!hasPermission(permissions, 'edit_content_views')}
            tooltip={dependenciesHelpText}
            boolean
            {...{ currentAttribute, setCurrentAttribute }}
          />)}
        <TextListItem component={TextListItemVariants.dt}>
          {LabelImportOnly()}
        </TextListItem>
        <TextListItem component={TextListItemVariants.dd} className="foreman-spaced-list">
          <Switch
            id="import_only_switch"
            aria-label="import_only_switch"
            isChecked={importOnly}
            className="foreman-spaced-list"
            disabled
          />
        </TextListItem>
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
    solve_dependencies: PropTypes.bool,
    auto_publish: PropTypes.bool,
    import_only: PropTypes.bool,
    permissions: PropTypes.shape({}),
  }).isRequired,
};

export default ContentViewInfo;
