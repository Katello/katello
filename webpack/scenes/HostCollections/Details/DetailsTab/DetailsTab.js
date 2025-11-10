import React from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Card,
  CardBody,
  CardTitle,
  DescriptionList,
  DescriptionListGroup,
  DescriptionListTerm,
  DescriptionListDescription,
  Grid,
  GridItem,
} from '@patternfly/react-core';
import InlineEdit from '../../../../components/InlineEdit';
import HostLimitEdit from './HostLimitEdit';
import { updateHostCollection, getHostCollection } from '../HostCollectionDetailsActions';

const DetailsTab = ({ hostCollection, hostCollectionId }) => {
  const dispatch = useDispatch();

  const handleSave = (field, value) => {
    const params = { [field]: value };
    dispatch(updateHostCollection(hostCollectionId, params, () => {
      dispatch(getHostCollection(hostCollectionId));
    }));
  };

  return (
    <Grid hasGutter>
      <GridItem span={12}>
        <Card isFullHeight ouiaId="host-collection-details-card">
          <CardTitle>{__('Basic Information')}</CardTitle>
          <CardBody>
            <DescriptionList isHorizontal>
              <DescriptionListGroup>
                <DescriptionListTerm>{__('Name')}</DescriptionListTerm>
                <DescriptionListDescription>
                  <InlineEdit
                    value={hostCollection?.name || ''}
                    onSave={value => handleSave('name', value)}
                    isRequired
                  />
                </DescriptionListDescription>
              </DescriptionListGroup>

              <DescriptionListGroup>
                <DescriptionListTerm>{__('Description')}</DescriptionListTerm>
                <DescriptionListDescription>
                  <InlineEdit
                    value={hostCollection?.description || ''}
                    onSave={value => handleSave('description', value)}
                    multiline
                  />
                </DescriptionListDescription>
              </DescriptionListGroup>

              <DescriptionListGroup>
                <DescriptionListTerm>{__('Total Hosts')}</DescriptionListTerm>
                <DescriptionListDescription>
                  <a href="#hosts">{hostCollection?.totalHosts || 0}</a>
                </DescriptionListDescription>
              </DescriptionListGroup>

              <DescriptionListGroup>
                <DescriptionListTerm>{__('Host Limit')}</DescriptionListTerm>
                <DescriptionListDescription>
                  <HostLimitEdit
                    hostCollection={hostCollection}
                    hostCollectionId={hostCollectionId}
                  />
                </DescriptionListDescription>
              </DescriptionListGroup>
            </DescriptionList>
          </CardBody>
        </Card>
      </GridItem>
    </Grid>
  );
};

DetailsTab.propTypes = {
  hostCollection: PropTypes.shape({
    name: PropTypes.string,
    description: PropTypes.string,
    totalHosts: PropTypes.number,
    maxHosts: PropTypes.number,
    unlimitedHosts: PropTypes.bool,
  }),
  hostCollectionId: PropTypes.string.isRequired,
};

DetailsTab.defaultProps = {
  hostCollection: {},
};

export default DetailsTab;
