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
import { dependenciesHelpText, autoPublishHelpText } from '../helpers';
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
  } = details;

  if (updating) return <Loading size="sm" showText={false} />;

  const onEdit = (val, attribute) => {
    if (val === details[attribute]) return;
    dispatch(updateContentView(cvId, { [attribute]: val }));
  };

  return (
    <TextContent>
      <TextList component={TextListVariants.dl}>
        <ActionableDetail
          label={__('Name')}
          attribute="name"
          onEdit={onEdit}
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
            <FlexItem spacer={{ default: 'spacerXs' }}><ContentViewIcon composite={composite} /></FlexItem>
            <FlexItem>{composite ? 'Composite' : 'Component'}</FlexItem>
          </Flex>
        </TextListItem>
        <ActionableDetail
          textArea
          label={__('Description')}
          attribute="description"
          onEdit={onEdit}
          value={description}
          {...{ currentAttribute, setCurrentAttribute }}
        />
        {composite ?
          (<ActionableDetail
            label={__('Autopublish')}
            attribute="auto_publish"
            value={autoPublish}
            onEdit={onEdit}
            tooltip={autoPublishHelpText}
            boolean
            {...{ currentAttribute, setCurrentAttribute }}
          />) :
          (<ActionableDetail
            label={__('Solve dependencies')}
            attribute="solve_dependencies"
            value={solveDependencies}
            onEdit={onEdit}
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
  }).isRequired,
};

export default ContentViewInfo;
