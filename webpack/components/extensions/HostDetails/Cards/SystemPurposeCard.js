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
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import PencilEditButton from '../../../EditableTextInput/PencilEditButton';
import './SystemPurposeCard.scss';

const SystemPurposeCard = ({ hostDetails }) => {
  const showEditButton = true;
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
                <FlexItem>
                  <CardTitle>{__('System purpose')}</CardTitle>
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
              <DescriptionListDescription>Red Hat Enterprise Linux Server</DescriptionListDescription>
              <DescriptionListTerm>{__('SLA')}</DescriptionListTerm>
              <DescriptionListDescription><Label color="blue">Premium</Label></DescriptionListDescription>
              <DescriptionListTerm>{__('Usage type')}</DescriptionListTerm>
              <DescriptionListDescription><Label color="blue">Production</Label></DescriptionListDescription>
              <DescriptionListTerm>{__('Release version')}</DescriptionListTerm>
              <DescriptionListDescription>5</DescriptionListDescription>
              <DescriptionListTerm>{__('Add-ons')}</DescriptionListTerm>
              <DescriptionListDescription>
                <List isPlain>
                  <ListItem>Add-on 1</ListItem>
                  <ListItem>Add-on 2</ListItem>
                </List>
              </DescriptionListDescription>
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
