import React, { useState } from 'react';
import {
  Card,
  CardHeader,
  CardTitle,
  CardBody,
  Dropdown,
  DropdownItem,
  Flex,
  FlexItem,
  GridItem,
  KebabToggle,
  Label,
  Tooltip,
} from '@patternfly/react-core';
import { FormattedMessage } from 'react-intl';

import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { translate as __ } from 'foremanReact/common/I18n';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import PropTypes from 'prop-types';
import ContentViewIcon from '../../../../../scenes/ContentViews/components/ContentViewIcon';
import { hostIsRegistered } from '../../hostDetailsHelpers';
import ChangeHostCVModal from './ChangeHostCVModal';

const HostContentViewDetails = ({
  contentView, lifecycleEnvironment, contentViewVersionId,
  contentViewVersion, contentViewVersionLatest, hostId, hostName,
}) => {
  let versionLabel = `Version ${contentViewVersion}`;
  if (contentViewVersionLatest) {
    versionLabel += ' (latest)';
  }

  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const toggleHamburger = () => setIsDropdownOpen(prev => !prev);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const closeModal = () => setIsModalOpen(false);
  const openModal = () => {
    setIsDropdownOpen(false);
    setIsModalOpen(true);
  };

  const dropdownItems = [
    <DropdownItem
      aria-label="change-host-content-view"
      key="change-host-content-view"
      component="button"
      onClick={openModal}
    >
      {__('Edit content view assignment')}
    </DropdownItem>,
  ];

  return (
    <GridItem rowSpan={1} md={6} lg={4} xl2={3} >
      <Card isHoverable>
        <CardHeader>
          <Flex
            alignItems={{ default: 'alignItemsCenter' }}
            justifyContent={{ default: 'justifyContentSpaceBetween' }}
            style={{ width: '100%' }}
          >
            <FlexItem>
              <Flex
                alignItems={{ default: 'alignItemsCenter' }}
                justifyContent={{ default: 'justifyContentSpaceBetween' }}
              >
                <FlexItem>
                  <CardTitle>{__('Content view details')}</CardTitle>
                </FlexItem>
              </Flex>
            </FlexItem>
            <FlexItem>
              <Dropdown
                toggle={<KebabToggle aria-label="change_content_view_hamburger" onToggle={toggleHamburger} />}
                isOpen={isDropdownOpen}
                isPlain
                ouiaId="change-host-content-view-kebab"
                position="right"
                dropdownItems={dropdownItems}
              />
            </FlexItem>
          </Flex>
        </CardHeader>
        <CardBody>
          <Flex direction={{ default: 'column' }}>
            <Flex
              direction={{ default: 'row', sm: 'row' }}
              flexWrap={{ default: 'nowrap' }}
              alignItems={{ default: 'alignItemsCenter', sm: 'alignItemsCenter' }}
            >
              <ContentViewIcon composite={contentView.composite} style={{ marginRight: '2px' }} position="left" />
              <h3>{__('Content view')}</h3>
            </Flex>
            <Flex direction={{ default: 'row', sm: 'row' }} flexWrap={{ default: 'wrap' }}>
              <a style={{ fontSize: '14px' }} href={`/content_views/${contentView.id}`}>{`${contentView.name}`}</a>
              <Tooltip
                position="top"
                enableFlip
                entryDelay={400}
                content={<FormattedMessage
                  id="cv-card-lce-tooltip"
                  defaultMessage={__('Lifecycle environment: {lce}')}
                  values={{
                    lce: lifecycleEnvironment.name,
                  }}
                />}
              >
                <Label isTruncated color="purple" href={`/lifecycle_environments/${lifecycleEnvironment.id}`}>{`${lifecycleEnvironment.name}`}</Label>
              </Tooltip>
            </Flex>
          </Flex>
          <Flex direction={{ default: 'column' }}>
            <FlexItem>
              <h3>{__('Version in use')}</h3>
              <a style={{ fontSize: '14px' }} href={urlBuilder(`content_views/${contentView.id}/versions/${contentViewVersionId}`, '')}>
                {versionLabel}
              </a>
            </FlexItem>
          </Flex>
        </CardBody>
      </Card>
      {hostId &&
        <ChangeHostCVModal
          isOpen={isModalOpen}
          closeModal={closeModal}
          hostId={hostId}
          key={`cv-change-modal-${hostId}`}
          hostName={hostName}
        />
      }
    </GridItem>
  );
};

const ContentViewDetailsCard = ({ hostDetails }) => {
  if (hostIsRegistered({ hostDetails }) && hostDetails.content_facet_attributes) {
    return (<HostContentViewDetails
      hostId={hostDetails.id}
      hostName={hostDetails.name}
      {...propsToCamelCase(hostDetails.content_facet_attributes)}
    />);
  }
  return null;
};

HostContentViewDetails.propTypes = {
  contentView: PropTypes.shape({
    name: PropTypes.string,
    id: PropTypes.number,
    composite: PropTypes.bool,
  }).isRequired,
  lifecycleEnvironment: PropTypes.shape({
    name: PropTypes.string,
    id: PropTypes.number,
  }).isRequired,
  contentViewVersionId: PropTypes.number.isRequired,
  contentViewVersion: PropTypes.string.isRequired,
  contentViewVersionLatest: PropTypes.bool.isRequired,
  id: PropTypes.number,
  name: PropTypes.string,
};

HostContentViewDetails.defaultProps = {
  id: null,
  name: '',
};

ContentViewDetailsCard.propTypes = {
  hostDetails: PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
    content_facet_attributes: PropTypes.shape({}),
  }),
};

ContentViewDetailsCard.defaultProps = {
  hostDetails: {},
};

export default ContentViewDetailsCard;
