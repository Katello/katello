import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  DataListItem,
  DataListItemRow,
  DataListItemCells,
  DataListCell,
  DataListToggle,
  DataListContent,
  DataListAction,
} from '@patternfly/react-core';
import { StarIcon } from '@patternfly/react-icons';
import { sprintf, translate as __ } from 'foremanReact/common/I18n';

import RepositoryTypeIcon from './RepositoryTypeIcon';
// eslint-disable-next-line import/no-named-as-default
import RepositorySetRepositories from './RepositorySetRepositories';

const RepositorySet = ({
  type, id, name, label, product, recommended,
}) => {
  const [isExpanded, setIsExpanded] = useState(false);

  return (
    <DataListItem
      aria-labelledby={`repository-set-${id}`}
      isExpanded={isExpanded}
      className={isExpanded ? 'repository-set-expanded' : ''}
    >
      <DataListItemRow
        className="repository-item-row"
        onClick={() => setIsExpanded(!isExpanded)}
        style={{ cursor: 'pointer' }}
      >
        <DataListToggle
          isExpanded={isExpanded}
          id={`toggle-${id}`}
          aria-controls={`expand-${id}`}
          className="repository-toggle-control"
        />
        <DataListItemCells
          dataListCells={[
            <DataListCell key="icon" className="repository-cell-icon">
              <div className="repository-icon-badge repository-icon-badge-blue">
                <RepositoryTypeIcon type={type} />
              </div>
            </DataListCell>,
            <DataListCell key="content" className="repository-cell-content">
              <div id={`repository-set-${id}`} className="repository-name">
                {name}
              </div>
              <div className="repository-label">{label}</div>
            </DataListCell>,
          ]}
        />
        {recommended && (
          <DataListAction>
            <StarIcon className="recommended-repository-set-icon" aria-hidden="true" />
          </DataListAction>
        )}
      </DataListItemRow>
      {isExpanded && (
        <DataListContent
          aria-label={sprintf(__('Details for %s'), name)}
          id={`expand-${id}`}
          isHidden={false}
          className="repository-expandable-content"
        >
          <RepositorySetRepositories
            contentId={id}
            productId={product.id}
            type={type}
            label={label}
          />
        </DataListContent>
      )}
    </DataListItem>
  );
};

RepositorySet.propTypes = {
  id: PropTypes.number.isRequired,
  type: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  label: PropTypes.string.isRequired,
  product: PropTypes.shape({
    name: PropTypes.string.isRequired,
    id: PropTypes.number.isRequired,
  }).isRequired,
  recommended: PropTypes.bool,
};

RepositorySet.defaultProps = {
  recommended: false,
};

export default RepositorySet;
