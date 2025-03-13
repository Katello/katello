import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  DescriptionList,
  DescriptionListGroup,
  DescriptionListDescription as Dd,
  DescriptionListTerm as Dt,
} from '@patternfly/react-core';
import CardTemplate from 'foremanReact/components/HostDetails/Templates/CardItem/CardTemplate';
import FontAwesomeImageModeIcon from '../../../../components/extensions/Hosts/FontAwesomeImageModeIcon';
import { createJob } from '../Tabs/customizedRexUrlHelpers';

const cardHeader = (
  <>
    <span style={{ marginRight: '0.5rem' }}>{__('Image mode details')}</span>
    <FontAwesomeImageModeIcon />
  </>
);
const actionUrl = hostname => createJob({
  hostname,
  feature: 'katello_bootc_action',
  inputs: {},
});

const ImageModeCard = ({ isExpandedGlobal, hostDetails }) => {
  const imageMode = hostDetails?.content_facet_attributes?.bootc_booted_image;
  if (!imageMode) return null;
  const getValueOrDash = value => (value || '—');
  return (
    <CardTemplate
      header={cardHeader}
      expandable
      masonryLayout
      isExpandedGlobal={isExpandedGlobal}
      ouiaId="image-mode"
    >
      <a href={actionUrl(hostDetails.name)}>{__('Modify via remote execution')}</a>
      <DescriptionList isHorizontal>
        <DescriptionListGroup>
          <Dt>{__('Running image')}</Dt>
          <Dd>{getValueOrDash(hostDetails.content_facet_attributes.bootc_booted_image)}</Dd>
          <Dt>{__('Running image digest')}</Dt>
          <Dd>{getValueOrDash(hostDetails.content_facet_attributes.bootc_booted_digest)}</Dd>

          <Dt>{__('Staged image')}</Dt>
          <Dd>{getValueOrDash(hostDetails.content_facet_attributes.bootc_staged_image)}</Dd>
          <Dt>{__('Staged image digest')}</Dt>
          <Dd>{getValueOrDash(hostDetails.content_facet_attributes.bootc_staged_digest)}</Dd>

          <Dt>{__('Available image')}</Dt>
          <Dd>{getValueOrDash(hostDetails.content_facet_attributes.bootc_available_image)}</Dd>
          <Dt>{__('Available image digest')}</Dt>
          <Dd>{getValueOrDash(hostDetails.content_facet_attributes.bootc_available_digest)}</Dd>

          <Dt>{__('Rollback image')}</Dt>
          <Dd>{getValueOrDash(hostDetails.content_facet_attributes.bootc_rollback_image)}</Dd>
          <Dt>{__('Rollback image digest')}</Dt>
          <Dd>{getValueOrDash(hostDetails.content_facet_attributes.bootc_rollback_digest)}</Dd>
        </DescriptionListGroup>
      </DescriptionList>
    </CardTemplate>
  );
};

ImageModeCard.propTypes = {
  isExpandedGlobal: PropTypes.bool,
  hostDetails: PropTypes.shape({
    name: PropTypes.string,
    content_facet_attributes: PropTypes.shape({
      bootc_booted_image: PropTypes.string,
      bootc_booted_digest: PropTypes.string,
      bootc_staged_image: PropTypes.string,
      bootc_staged_digest: PropTypes.string,
      bootc_available_image: PropTypes.string,
      bootc_available_digest: PropTypes.string,
      bootc_rollback_image: PropTypes.string,
      bootc_rollback_digest: PropTypes.string,
    }),
  }),
};

ImageModeCard.defaultProps = {
  isExpandedGlobal: false,
  hostDetails: {},
};

export default ImageModeCard;
