import React from 'react';
import PropTypes from 'prop-types';
import {
  Badge,
  Card,
  CardHeader,
  CardTitle,
  CardBody,
  DescriptionList,
  DescriptionListGroup,
  DescriptionListDescription,
  DescriptionListTerm,
  Flex,
  FlexItem,
  GridItem,
  Label,
  List,
  ListItem,
  Tooltip,
} from '@patternfly/react-core';
import { OutlinedQuestionCircleIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import PencilEditButton from '../../../EditableTextInput/PencilEditButton';
import './SystemPurposeCard.scss';

const SystemPurposeCard = ({ hostDetails }) => {
  const showEditButton = true;
  const subscriptionFacetAttributes = hostDetails?.subscription_facet_attributes;
  const {
    purposeRole, purposeUsage, purposeAddons, releaseVersion, serviceLevel,
  } = propsToCamelCase(subscriptionFacetAttributes);
  return (
    <GridItem rowSpan={1} md={6} lg={4} xl2={3}>
      <Card isHoverable ouiaId="system-purpose-card">
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
                <FlexItem style={{ marginRight: '0.5em' }}>
                  <CardTitle>{__('System purpose')}</CardTitle>
                </FlexItem>
                <FlexItem>
                  <Tooltip
                    content={__('System purpose allows you to set the system\'s intended use on your network and improves the reporting of usage in Subscription Watch.')}
                    position="top"
                    enableFlip
                    isContentLeftAligned
                  >
                    <OutlinedQuestionCircleIcon style={{ marginTop: '7px' }} color="gray" />
                  </Tooltip>
                </FlexItem>
              </Flex>
            </FlexItem>
            {showEditButton && (
              <FlexItem>
                <PencilEditButton attribute="system_purpose" onEditClick={() => {}} />
              </FlexItem>)
            }
          </Flex>
        </CardHeader>
        <CardBody className="system-purpose-card-body">
          <DescriptionList isHorizontal>
            <DescriptionListGroup>
              <DescriptionListTerm>{__('Role')}</DescriptionListTerm>
              <DescriptionListDescription>{purposeRole}</DescriptionListDescription>
              <DescriptionListTerm>{__('SLA')}</DescriptionListTerm>
              <DescriptionListDescription>
                {serviceLevel && (
                  <Label color="blue">{serviceLevel}</Label>
                )}
              </DescriptionListDescription>
              <DescriptionListTerm>{__('Usage type')}</DescriptionListTerm>
              <DescriptionListDescription>
                {purposeUsage && (
                  <Label color="blue">{purposeUsage}</Label>
                )}
              </DescriptionListDescription>
              <DescriptionListTerm>{__('Release version')}</DescriptionListTerm>
              <DescriptionListDescription>{releaseVersion}</DescriptionListDescription>
              {purposeAddons.length > 0 && (
                <>
                  <DescriptionListTerm>{__('Add-ons')}</DescriptionListTerm>
                  <DescriptionListDescription>
                    <List isPlain>
                      {purposeAddons.map(addon => (
                        <ListItem key={addon}>{addon}</ListItem>
                      ))}
                    </List>
                  </DescriptionListDescription>
                </>
              )
              }
            </DescriptionListGroup>
          </DescriptionList>
        </CardBody>
      </Card>
    </GridItem>
  );
};

SystemPurposeCard.propTypes = {
  hostDetails: PropTypes.shape({
    subscription_facet_attributes: PropTypes.shape({
      installed_products: PropTypes.arrayOf(PropTypes.shape({
        productId: PropTypes.string,
        productName: PropTypes.string,
      })),
    }),
  }),
};

SystemPurposeCard.defaultProps = {
  hostDetails: {},
};

export default SystemPurposeCard;
