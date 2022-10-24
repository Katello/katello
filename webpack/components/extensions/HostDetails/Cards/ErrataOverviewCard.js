import React, { useState } from 'react';
import {
  Card,
  CardHeader,
  CardTitle,
  CardBody,
  Flex,
  FlexItem,
  GridItem,
  ToggleGroup,
  ToggleGroupItem,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import PropTypes from 'prop-types';
import { ChartPie } from '@patternfly/react-charts';
import { ErrataMapper } from '../../../../components/Errata';
import { hostIsRegistered } from '../hostDetailsHelpers';
import { TranslatedAnchor } from '../../../Table/components/TranslatedPlural';
import EmptyStateMessage from '../../../Table/EmptyStateMessage';
import './ErrataOverviewCard.scss';

function HostInstallableErrata({
  id, errataCounts, errataStatus, errataCategory,
}) {
  const counts = errataCategory === 'applicable' ? errataCounts.applicable : errataCounts;
  const show = errataCategory === 'applicable' ? 'all' : 'installable';
  const errataTotal = counts.total;
  const errataSecurity = counts.security;
  const errataBug = counts.bugfix;
  const errataEnhance = counts.enhancement;
  const chartData = [{
    w: 'security advisories', x: 'security', y: errataSecurity, z: errataTotal,
  }, {
    w: 'bug fixes', x: 'bugfix', y: errataBug, z: errataTotal,
  }, {
    w: 'enhancements', x: 'enhancement', y: errataEnhance, z: errataTotal,
  }];
  return (
    <CardBody>
      {errataStatus === 0 &&
        <EmptyStateMessage
          title={__('All errata up-to-date')}
          body={__('No action required')}
          happy
        />
      }
      {errataStatus !== 0 &&
        <Flex direction="column">
          <FlexItem>
            <TranslatedAnchor
              id="errata-card-total-count"
              href={`#/Content/errata?show=${show}`}
              count={errataTotal}
              plural="errata"
              singular="erratum"
              ariaLabel={`${errataTotal} total errata`}
            />
          </FlexItem>
          <Flex flexWrap={{ xl: 'nowrap' }} direction="row" alignItems={{ default: 'alignItemsCenter' }}>
            <div className="piechart-overflow" style={{ overflow: 'visible', minWidth: '140px', maxHeight: '155px' }}>
              <div className="erratachart" style={{ minWidth: '300px', minHeight: '300px' }}>
                <ChartPie
                  ariaDesc="errataChart"
                  data={chartData}
                  constrainToVisibleArea
                  labels={({ datum }) => `${datum.y} ${datum.w}`}
                  padding={{
                    bottom: 20,
                    left: 20,
                    right: 140,
                    top: 20,
                  }}
                  width={250}
                  height={130}
                />
              </div>
            </div>
            <div className="erratalegend" style={{ minWidth: '140px' }}>
              <FlexItem>
                <ErrataMapper data={chartData} id={id} errataCategory={errataCategory} />
              </FlexItem>
            </div>
          </Flex>
        </Flex>
      }
    </CardBody>
  );
}

const ErrataOverviewCard = ({ hostDetails }) => {
  const hostPopulated = (hostIsRegistered({ hostDetails }) &&
    !!hostDetails.content_facet_attributes);

  const [errataCategory, setErrataCategory] = useState('applicable');
  if (!hostPopulated) return null;
  const { id: hostId, errata_status: errataStatus } = hostDetails;
  return (
    <GridItem rowSpan={1} md={6} lg={4} xl2={3} >
      <Card ouiaId="errata-card">
        <CardHeader>
          <Flex spaceItems={{ default: 'spaceItemsXl' }}>
            <CardTitle>{__('Errata')}</CardTitle>
            {errataStatus !== 0 &&
              <ToggleGroup>
                <ToggleGroupItem
                  text={__('Installable')}
                  isSelected={errataCategory === 'installable'}
                  onChange={selected => selected && setErrataCategory('installable')}
                />
                <ToggleGroupItem
                  text={__('Applicable')}
                  isSelected={errataCategory === 'applicable'}
                  onChange={selected => selected && setErrataCategory('applicable')}
                />
              </ToggleGroup>
            }
          </Flex>
        </CardHeader>
        <HostInstallableErrata
          {...propsToCamelCase(hostDetails.content_facet_attributes)}
          id={hostId}
          errataCategory={errataCategory}
          errataStatus={errataStatus}
        />
      </Card>
    </GridItem>
  );
};

HostInstallableErrata.propTypes = {
  id: PropTypes.number.isRequired,
  errataCounts: PropTypes.shape({
    bugfix: PropTypes.number,
    enhancement: PropTypes.number,
    security: PropTypes.number,
    total: PropTypes.number,
    applicable: PropTypes.shape({
      bugfix: PropTypes.number,
      enhancement: PropTypes.number,
      security: PropTypes.number,
    }),
  }).isRequired,
  errataStatus: PropTypes.number,
  errataCategory: PropTypes.string,
};

HostInstallableErrata.defaultProps = {
  errataStatus: undefined,
  errataCategory: 'applicable',
};

ErrataOverviewCard.propTypes = {
  hostDetails: PropTypes.shape({
    content_facet_attributes: PropTypes.shape({}),
    id: PropTypes.number,
    errata_status: PropTypes.number,
  }),
};

ErrataOverviewCard.defaultProps = {
  hostDetails: {},
};

export default ErrataOverviewCard;
