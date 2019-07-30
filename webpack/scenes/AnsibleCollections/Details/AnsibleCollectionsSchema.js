import React from 'react';
import ContentDetailInfo from '../../../components/Content/Details/ContentDetailInfo';
import ContentDetailRepositories   from '../../../components/Content/Details/ContentDetailRepositories';

export default (detailInfo) => {
  const { repositories } = detailInfo;

  const displayMap = new Map([
    ['name', __('Name')],
    ['namespace', __('Namespace')],
    ['version', __('Version')],
    ['checksum', __('Checksum')],
  ]);

  return [
    {
      tabHeader: __('Details'),
      tabContent: (
        <ContentDetailInfo contentDetails={detailInfo} displayMap={displayMap} />
      ),
    },
    {
      tabHeader: __('Repositories'),
      tabContent: (repositories && repositories.length ?
        <ContentDetailRepositories repositories={repositories} /> :
        __('No repositories to show')
      ),
    },
  ];
};