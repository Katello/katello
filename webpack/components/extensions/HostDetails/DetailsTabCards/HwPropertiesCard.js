import React from 'react';
import PropTypes from 'prop-types';
import { number_to_human_size as NumberToHumanSize } from 'number_helpers';
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

const HostDisks = ({ blockDevices }) => {
  if (!blockDevices) return null;
  // blockDevices fact will look like this by default 'sr0,sda' and increment like sdb etc
  const disks = blockDevices.split(',');
  // We are filtering out the CDROM drive that gets added by default a lot of the time
  const totalDisks = disks.filter(e => !e.startsWith('sr')).length;
  if (!totalDisks) return null;
  return (
    <>
      <DescriptionListTerm>{__('Storage')}</DescriptionListTerm>
      <Text component={TextVariants.h4} ouiaId="storage-text">
        <TranslatedPlural count={totalDisks} singular={__('disk')} id="total-disks" />
      </Text>
    </>
  );
};

HostDisks.propTypes = {
  blockDevices: PropTypes.string,
};

HostDisks.defaultProps = {
  blockDevices: '',
};

const HwPropertiesCard = ({ isExpandedGlobal, hostDetails }) => {
  if (hostIsNotRegistered({ hostDetails })) return null;
  const { facts } = hostDetails || {};
  const model = facts?.['virt::host_type'];
  const cpuCount = facts?.['cpu::cpu(s)'];
  const cpuSockets = facts?.['cpu::cpu_socket(s)'];
  const coreSocket = facts?.['cpu::core(s)_per_socket'];
  const blockDevices = facts?.blockdevices;
  const memory = facts?.['memory::memtotal'];

  return (
    <CardTemplate
      header={__('HW properties')}
      expandable
      isExpandedGlobal={isExpandedGlobal}
      masonryLayout
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
          <DescriptionListDescription>
            {NumberToHumanSize(memory * 1024, {
              strip_insignificant_zeros: true,
            })}
          </DescriptionListDescription>
        </DescriptionListGroup>
        <DescriptionListGroup>
          <HostDisks blockDevices={blockDevices} />
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
      blockdevices: PropTypes.string,
    }),
  }),
};

HwPropertiesCard.defaultProps = {
  isExpandedGlobal: false,
  hostDetails: {},
};

export default HwPropertiesCard;
