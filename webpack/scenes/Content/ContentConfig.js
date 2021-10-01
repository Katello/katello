import React from 'react';
import { Link } from 'react-router-dom';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { translate as __ } from 'foremanReact/common/I18n';
import ContentInfo from './Details/ContentInfo';
import LastSync from '../ContentViews/Details/Repositories/LastSync';
import ContentRepositories from './Details/ContentRepositories';
import ContentCounts from './Details/ContentCounts';

export default () => [
  {
    names: {
      pluralTitle: __('Python Packages'),
      singularTitle: __('Python Package'),
      pluralLowercase: __('Python packages'),
      singularLowercase: __('Python package'),
      pluralLabel: 'python_packages',
      singularLabel: 'python_package',
    },
    columnHeaders: [
      { title: __('Name'), getProperty: unit => (<Link to={urlBuilder(`content/python_packages/${unit?.id}`, '')}>{unit?.name}</Link>) },
      { title: __('Version'), getProperty: unit => unit?.version },
    ],
    tabs: [
      {
        tabKey: 'details',
        title: __('Details'),
        getContent: (contentType, id, tabKey) => <ContentInfo {...{ contentType, id, tabKey }} />,
        columnHeaders: [
          { title: __('Name'), getProperty: unit => unit?.name },
          { title: __('Version'), getProperty: unit => unit?.version },
        ],
      },
      {
        tabKey: 'repositories',
        title: __('Repositories'),
        getContent: (contentType, id, tabKey) =>
          <ContentRepositories {...{ contentType, id, tabKey }} />,
        columnHeaders: [
          {
            title: __('Name'),
            getProperty: unit =>
              <a href={urlBuilder(`products/${unit?.product.id}/repositories/${unit?.id}`, '')}>{unit?.name}</a>,
          },
          {
            title: __('Product'),
            getProperty: unit =>
              <a href={urlBuilder(`products/${unit?.product.id}/repositories`, '')}>{unit?.product.name}</a>,
          },
          {
            title: __('Sync Status'),
            getProperty: unit =>
              <LastSync lastSyncWords={unit?.last_sync_words} lastSync={unit?.last_sync} />,
          },
          {
            title: __('Content Count'),
            getProperty: (unit, singularLabel) =>
              (<ContentCounts
                typeSingularLabel={singularLabel}
                productId={unit.product.id}
                repoId={unit.id}
                counts={unit.content_counts}
              />),
          },
        ],
      },
    ],
  },
];
