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
      { title: __('Filename'), getProperty: unit => unit?.filename },
    ],
    tabs: [
      {
        tabKey: 'details',
        title: __('Details'),
        getContent: (contentType, id, tabKey) => <ContentInfo {...{ contentType, id, tabKey }} />,
        columnHeaders: [
          { title: __('Name'), getProperty: unit => unit?.name },
          { title: __('Version'), getProperty: unit => unit?.version },
          { title: __('Filename'), getProperty: unit => unit?.filename },
          { title: __('Package Type'), getProperty: unit => unit?.additional_metadata.package_type },
          { title: __('sha256'), getProperty: unit => unit?.additional_metadata.sha256 },
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
              <a href={urlBuilder(`products/${unit?.product.id}/`, '')}>{unit?.product.name}</a>,
          },
          {
            title: __('Sync Status'),
            getProperty: unit =>
              (<LastSync
                startedAt={unit?.last_sync?.started_at}
                lastSyncWords={unit?.last_sync_words}
                lastSync={unit?.last_sync}
              />),
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
  {
    names: {
      pluralTitle: __('Ansible Collections'),
      singularTitle: __('Ansible Collection'),
      pluralLowercase: __('Ansible collections'),
      singularLowercase: __('Ansible collection'),
      pluralLabel: 'ansible_collections',
      singularLabel: 'ansible_collection',
    },
    columnHeaders: [
      { title: __('Name'), getProperty: unit => (<Link to={urlBuilder(`content/ansible_collections/${unit?.id}`, '')}>{unit?.name}</Link>) },
      { title: __('Author'), getProperty: unit => unit?.namespace },
      { title: __('Version'), getProperty: unit => unit?.version },
      { title: __('Checksum'), getProperty: unit => unit?.checksum },

    ],
    tabs: [
      {
        tabKey: 'details',
        title: __('Details'),
        getContent: (contentType, id, tabKey) => <ContentInfo {...{ contentType, id, tabKey }} />,
        columnHeaders: [
          { title: __('Name'), getProperty: unit => unit?.name },
          { title: __('Description'), getProperty: unit => unit?.description },
          { title: __('Author'), getProperty: unit => unit?.namespace },
          { title: __('Version'), getProperty: unit => unit?.version },
          { title: __('Checksum'), getProperty: unit => unit?.checksum },
          { title: __('Tags'), getProperty: unit => unit?.tags?.join() },
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
              <a href={urlBuilder(`products/${unit?.product.id}`, '')}>{unit?.product.name}</a>,
          },
          {
            title: __('Sync Status'),
            getProperty: unit =>
              (<LastSync
                startedAt={unit?.started_at}
                lastSyncWords={unit?.last_sync_words}
                lastSync={unit?.last_sync}
              />),
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
