import React from 'react';
import PropTypes from 'prop-types';
import {
  GridItem,
  TextContent,
  Text,
  TextList,
  TextVariants,
  TextListVariants,
  Label,
  Flex,
  FlexItem,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import EditableTextInput from '../../../../../components/EditableTextInput';
import { hasPermission } from '../../../helpers';

const ContentViewVersionDetailsHeader = ({
  versionDetails: {
    version, description, environments,
  },
  onEdit,
  details: { permissions },
}) => (
  <>
    <GridItem span={12}>
      <TextContent>
        <Text component={TextVariants.h2}>{__('Version ')}{version}</Text>
      </TextContent>
    </GridItem>
    <GridItem className="content-view-header-content" span={12}>
      <TextContent>
        <TextList component={TextListVariants.dl}>
          <EditableTextInput
            key={description} // This fixes a render issue with the initial value
            textArea
            label={__('Description')}
            attribute="description"
            placeholder={__('No description')}
            onEdit={onEdit}
            disabled={!hasPermission(permissions, 'edit_content_views')}
            value={description}
          />
        </TextList>
      </TextContent>
      <Flex>
        {environments?.map(({ name, id }) =>
          <FlexItem key={name}><Label isTruncated color="purple" href={`/lifecycle_environments/${id}`}>{name}</Label></FlexItem>)}
      </Flex>
    </GridItem>
  </>
);

ContentViewVersionDetailsHeader.propTypes = {
  versionDetails: PropTypes.shape({
    version: PropTypes.string,
    environments: PropTypes.arrayOf(PropTypes.shape({})),
    description: PropTypes.string,
  }).isRequired,
  onEdit: PropTypes.func.isRequired,
  details: PropTypes.shape({
    permissions: PropTypes.shape({}),
  }).isRequired,
};

export default ContentViewVersionDetailsHeader;
