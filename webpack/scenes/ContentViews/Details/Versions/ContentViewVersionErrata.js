import React from 'react';
import PropTypes from 'prop-types';
import {
  BugIcon,
  SecurityIcon,
  EnhancementIcon,
} from '@patternfly/react-icons';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import './ContentViewVersionErrata.scss';

const ContentViewVersionErrata = ({ cvId, versionId, errataCounts }) => {
  const {
    total,
  } = errataCounts;

  const errataIcons = {
    security: SecurityIcon,
    bugfix: BugIcon,
    enhancement: EnhancementIcon,
  };

  const getHref = type => `/content_views/${cvId}/versions/${versionId}/errata?queryPagedSearch=%20type%20%3D%20${type}`;

  const ErrataLinkwithIcon = () => Object.keys(errataIcons).map((type) => {
    const ErrataIcon = errataIcons[type];
    return (
      <React.Fragment key={type}>
        <ErrataIcon title={type} />
        <a className="errata-icons-with-commas" href={getHref(type)}> {`${errataCounts[type] || '0'}`} </a>
      </React.Fragment>
    );
  });

  return (
    <React.Fragment>
      <a href={urlBuilder(`content_views/${cvId}/versions/${versionId}/errata`, '')}>{`${total || 0} `}</a>
      (<ErrataLinkwithIcon />)
    </React.Fragment>
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
