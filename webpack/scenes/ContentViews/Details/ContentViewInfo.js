import React from 'react';
import { useDispatch, useSelector } from 'react-redux';
import {
  Flex,
  FlexItem,
  TextContent,
  TextList,
  TextListVariants,
  TextListItem,
  TextListItemVariants,
} from '@patternfly/react-core';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';

import { updateContentView } from './ContentViewDetailActions';
import { selectIsCVUpdating } from './ContentViewDetailSelectors';
import Loading from '../../../components/Loading';
import ContentViewIcon from '../components/ContentViewIcon';
import ActionableDetail from '../../../components/ActionableDetail';
import './contentViewInfo.scss';

const ContentViewInfo = ({ cvId, details }) => {
  const dispatch = useDispatch();
  const updating = useSelector(state => selectIsCVUpdating(state));
  const {
    name,
    label,
    description,
    composite,
    solve_dependencies: solveDependencies,
    auto_publish: autoPublish,
  } = details;

  const autoPublishTooltip = __('Applicable only for composite views. Auto publish composite ' +
    'view when a new version of a component content view is created. Also note auto publish will ' +
    'only happen when the component is marked "latest".');

  const solveDependenciesTooltip = __('This option will solve RPM and Module Stream dependencies ' +
    'on every publish of this Content View. Dependency solving significantly increases publish ' +
    'time (publishes can take over three times as long) and filters will be ignored when adding ' +
    'packages to solve dependencies. Also, certain scenarios involving errata may still cause ' +
    'dependency errors.');


  if (updating) return <Loading size="sm" showText={false} />;
  const onEdit = (val, attribute) => dispatch(updateContentView(cvId, { [attribute]: val }));
  return (
    <TextContent>
      <TextList component={TextListVariants.dl}>
        <ActionableDetail
          label={__('Name')}
          attribute="name"
          onEdit={onEdit}
          value={name}
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
            <FlexItem>{ composite ? 'Composite' : 'Component' }</FlexItem>
          </Flex>
        </TextListItem>
        <ActionableDetail
          label={__('Description')}
          attribute="description"
          onEdit={onEdit}
          value={description}
        />
        {composite ?
          (<ActionableDetail
            label={__('Auto Publish')}
            attribute="auto_publish"
            value={autoPublish}
            onEdit={onEdit}
            tooltip={autoPublishTooltip}
            boolean
          />) :
          (<ActionableDetail
            label={__('Solve Dependencies')}
            attribute="solve_dependencies"
            value={solveDependencies}
            onEdit={onEdit}
            tooltip={solveDependenciesTooltip}
            boolean
          />)}
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
  }).isRequired,
};

export default ContentViewInfo;
