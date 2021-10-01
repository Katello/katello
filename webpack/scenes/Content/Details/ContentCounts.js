import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import ContentConfig from '../ContentConfig';

const appendCount = (type, count, info, productId, repoId) => {
  const [repoPlural, repoSingular, link] = info;
  const displayName = count > 1 ? repoPlural : repoSingular;
  const url = urlBuilder(`products/${productId}/repositories/${repoId}/content`, '', link);
  const displayInfo = `${count} ${displayName}`;
  return (
    <div key={`${type}${count}`}>
      <a href={url}>{displayInfo}</a>
    </div>
  );
};

const ContentCounts = ({
  typeSingularLabel, productId, repoId, counts,
}) => {
  const config = ContentConfig().find(type =>
    type.names.singularLabel === typeSingularLabel);
  const { pluralLowercase, singularLowercase, pluralLabel } = config.names;
  const info = [pluralLowercase, singularLowercase, pluralLabel];

  const allCounts = [];
  Object.keys(counts).forEach((type) => {
    const count = counts[typeSingularLabel];
    if (count > 0) allCounts.push(appendCount(type, count, info, productId, repoId));
  });

  return <Fragment>{allCounts}</Fragment>;
};

ContentCounts.propTypes = {
  typeSingularLabel: PropTypes.string.isRequired,
  productId: PropTypes.number.isRequired,
  repoId: PropTypes.number.isRequired,
  counts: PropTypes.shape({}).isRequired,
};

export default ContentCounts;
