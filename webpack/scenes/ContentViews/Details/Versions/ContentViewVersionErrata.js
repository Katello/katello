import React from 'react';
import PropTypes from 'prop-types';
import {
  BugIcon,
  SecurityIcon,
  EnhancementIcon,
} from '@patternfly/react-icons';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { translate as __ } from 'foremanReact/common/I18n';
import './ContentViewVersionErrata.scss';
import InactiveText from '../../components/InactiveText';

const ContentViewVersionErrata = ({ cvId, versionId, errataCounts }) => {
  const {
    total,
  } = errataCounts;

  const errataIcons = {
    security: SecurityIcon,
    bugfix: BugIcon,
    enhancement: EnhancementIcon,
  };

  const ErrataLinkwithIcon = () => Object.keys(errataIcons).map((type) => {
    const ErrataIcon = errataIcons[type];
    return (
      <React.Fragment key={type}>
        <ErrataIcon title={type} />
        <p className="errata-icons-with-commas">{errataCounts[type] || '0'}</p>
      </React.Fragment>
    );
  });

  if (total === 0) {
    return <InactiveText text={__('No errata')} />;
  }

  return (
    <>
      <a href={urlBuilder(`content_views/${cvId}#/versions/${versionId}/errata`, '')}>
        {total || 0}{' '}
      </a>
      ( <ErrataLinkwithIcon /> )
    </>
  );
};

ContentViewVersionErrata.propTypes = {
  cvId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  versionId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  errataCounts: PropTypes.shape({
    security: PropTypes.number,
    bugfix: PropTypes.number,
    enhancement: PropTypes.number,
    total: PropTypes.number,
  }),
};

ContentViewVersionErrata.defaultProps = {
  cvId: '',
  versionId: '',
  errataCounts: {
    security: 0,
    bugfix: 0,
    enhancement: 0,
    total: 0,
  },
};

export default ContentViewVersionErrata;
