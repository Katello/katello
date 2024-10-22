import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { useForemanHostsPageUrl } from 'foremanReact/Root/Context/ForemanContext';
import RelatedCompositeContentViewsModal from './RelatedCompositeContentViewsModal';
import RelatedContentViewComponentsModal from './RelatedContentViewComponentsModal';

const DetailsExpansion = ({
  cvId, cvName, cvComposite, cvRolling, activationKeys, hosts, relatedCVCount, relatedCompositeCVs,
}) => {
  const activationKeyCount = activationKeys.length;
  const hostCount = hosts.length;

  const baseHostsPageUrl = useForemanHostsPageUrl();
  const hostsPageUrl = `${baseHostsPageUrl}?search=${encodeURIComponent(`content_view_id=${cvId}`)}`;

  const relatedContentViewModal = () => {
    if (cvRolling) {
      return <></>;
    }
    if (cvComposite) {
      return (
        <>
          {__('Related content views: ')}
          <RelatedContentViewComponentsModal key="cvId" {...{ cvName, cvId, relatedCVCount }} />
        </>
      );
    }
    return (
      <>
        {__('Related composite content views: ')}
        <RelatedCompositeContentViewsModal
          key={cvId}
          {...{
            cvName, cvId, relatedCVCount, relatedCompositeCVs,
          }}
        />
      </>
    );
  };

  return (
    <div id={`cv-details-expansion-${cvId}`}>
      {__('Activation keys: ')}<a aria-label={`activation_keys_link_${cvId}`} href={`/activation_keys?search=content_view_id+%3D+${cvId}`}>{activationKeyCount}</a>
      <br />
      {__('Hosts: ')}<a aria-label={`host_link_${cvId}`} href={hostsPageUrl}>{hostCount}</a>
      <br />
      {relatedContentViewModal()}
    </div>
  );
};

DetailsExpansion.propTypes = {
  cvId: PropTypes.number.isRequired,
  activationKeys: PropTypes.arrayOf(PropTypes.shape({})),
  hosts: PropTypes.arrayOf(PropTypes.shape({})),
  cvName: PropTypes.string,
  cvComposite: PropTypes.bool,
  cvRolling: PropTypes.bool,
  relatedCompositeCVs: PropTypes.arrayOf(PropTypes.shape({})),
  relatedCVCount: PropTypes.number,
};

DetailsExpansion.defaultProps = {
  activationKeys: [],
  hosts: [],
  cvName: '',
  cvComposite: false,
  cvRolling: false,
  relatedCompositeCVs: [],
  relatedCVCount: 0,

};

export default DetailsExpansion;
