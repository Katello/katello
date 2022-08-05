import React from 'react';
import PropTypes from 'prop-types';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  DescriptionList,
  DescriptionListTerm,
  DescriptionListGroup,
  DescriptionListDescription,
  Text,
  TextVariants,
} from '@patternfly/react-core';
import CardTemplate from 'foremanReact/components/HostDetails/Templates/CardItem/CardTemplate';
import { TranslatedPlural } from '../../../Table/components/TranslatedPlural';
import { hostIsNotRegistered } from '../hostDetailsHelpers';

const HostDisks = ({ totalDisks }) => {
  if (!totalDisks) return null;
  return (
    <>
      <DescriptionListTerm>{__('Storage')}</DescriptionListTerm>
      <Text component={TextVariants.h4}><TranslatedPlural count={totalDisks} singular={__('disk')} id="total-disks" /></Text>
    </>
  );
};

HostDisks.propTypes = {
  totalDisks: PropTypes.number,
};

HostDisks.defaultProps = {
  totalDisks: null,
};

const HwPropertiesCard = ({ isExpandedGlobal, hostDetails }) => {
  if (hostIsNotRegistered({ hostDetails })) return null;
  const { facts } = hostDetails || {};
  const model = facts?.['virt::host_type'];
  const cpuCount = facts?.['cpu::cpu(s)'];
  const cpuSockets = facts?.['cpu::cpu_socket(s)'];
  const coreSocket = facts?.['cpu::core(s)_per_socket'];
  const reportedFacts = propsToCamelCase(hostDetails?.reported_data || {});
  const totalDisks = reportedFacts?.disksTotal;
  const memory = facts?.['dmi::memory::maximum_capacity'];

  return (
    <CardTemplate
      header={__('HW properties')}
      expandable
      isExpandedGlobal={isExpandedGlobal}
    >
      <DescriptionList isHorizontal>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Model')}</DescriptionListTerm>
          <DescriptionListDescription>{model}</DescriptionListDescription>
        </DescriptionListGroup>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Number of CPU(s)')}</DescriptionListTerm>
          <DescriptionListDescription>{cpuCount}</DescriptionListDescription>
        </DescriptionListGroup>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Sockets')}</DescriptionListTerm>
          <DescriptionListDescription>{cpuSockets}</DescriptionListDescription>
        </DescriptionListGroup>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('Cores per socket')}</DescriptionListTerm>
          <DescriptionListDescription>{coreSocket}</DescriptionListDescription>
        </DescriptionListGroup>
        <DescriptionListGroup>
          <DescriptionListTerm>{__('RAM')}</DescriptionListTerm>
          <DescriptionListDescription>{memory}</DescriptionListDescription>
        </DescriptionListGroup>
        <DescriptionListGroup>
          <HostDisks totalDisks={totalDisks} />
        </DescriptionListGroup>
      </DescriptionList>
    </CardTemplate>
  );
};

HwPropertiesCard.propTypes = {
  isExpandedGlobal: PropTypes.bool,
  hostDetails: PropTypes.shape({
    facts: PropTypes.shape({
      model: PropTypes.string,
      cpuCount: PropTypes.number,
      cpuSockets: PropTypes.number,
      coreSocket: PropTypes.number,
      memory: PropTypes.string,
    }),
    reported_data: PropTypes.shape({
      totalDisks: PropTypes.number,
    }),
  }),
};

HwPropertiesCard.defaultProps = {
  isExpandedGlobal: false,
  hostDetails: {},
};

export default HwPropertiesCard;
