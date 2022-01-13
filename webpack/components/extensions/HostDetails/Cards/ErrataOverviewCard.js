import React from 'react';
import {
  Card,
  CardHeader,
  CardTitle,
  CardBody,
  Flex,
  FlexItem,
  GridItem,
} from '@patternfly/react-core';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { translate as __ } from 'foremanReact/common/I18n';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import PropTypes from 'prop-types';
import { ChartPie } from '@patternfly/react-charts';
import { ErrataMapper } from '../../../../components/Errata';

function HostInstallableErrata({
  id, errataCounts,
}) {
  const errataTotal = errataCounts.total;
  const errataSecurity = errataCounts.security;
  const errataBug = errataCounts.bugfix;
  const errataEnhance = errataCounts.enhancement;
  const chartData = [{
    w: 'security advisories', x: 'security', y: errataSecurity, z: errataTotal,
  }, {
    w: 'bug fixes', x: 'bugfix', y: errataBug, z: errataTotal,
  }, {
    w: 'enhancements', x: 'enhancement', y: errataEnhance, z: errataTotal,
  }];
  return (
    <GridItem rowSpan={1} md={6} lg={4} xl2={3} >
      <Card isHoverable>
        <CardHeader>
          <CardTitle>{__('Installable Errata')}</CardTitle>
        </CardHeader>
        <CardBody>
          <Flex direction="column">
            <FlexItem>
              <a href={urlBuilder(`content_hosts/${id}/errata`, '')}>
                {errataTotal} errata
              </a>
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
                  <ErrataMapper data={chartData} id={id} />
                </FlexItem>
              </div>
            </Flex>
          </Flex>
        </CardBody>
      </Card>
    </GridItem>
  );
}

const ErrataOverviewCard = ({ hostDetails }) => {
  if (hostDetails.content_facet_attributes) {
    const { id: hostId } = hostDetails;
    return (<HostInstallableErrata
      {...propsToCamelCase(hostDetails.content_facet_attributes)}
      id={hostId}
    />);
  }
  return null;
};

HostInstallableErrata.propTypes = {
  id: PropTypes.number.isRequired,
  errataCounts: PropTypes.shape({
    bugfix: PropTypes.number,
    enhancement: PropTypes.number,
    security: PropTypes.number,
    total: PropTypes.number,
  }).isRequired,
};

ErrataOverviewCard.propTypes = {
  hostDetails: PropTypes.shape({
    content_facet_attributes: PropTypes.shape({}),
    id: PropTypes.number,
  }),
};

ErrataOverviewCard.defaultProps = {
  hostDetails: {},
};

export default ErrataOverviewCard;
