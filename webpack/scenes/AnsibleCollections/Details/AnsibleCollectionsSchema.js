import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import ContentDetailInfo from '../../../components/Content/Details/ContentDetailInfo';
import ContentDetailRepositories from '../../../components/Content/Details/ContentDetailRepositories';

export const displayMap = new Map([
  ['name', __('Name')],
  ['description', __('Description')],
  ['namespace', __('Author')],
  ['version', __('Version')],
  ['checksum', __('Checksum')],
  ['tags', __('Tags')],
]);

export default (detailInfo) => {
  const { repositories } = detailInfo;

  return [
    {
      key: 1,
      tabHeader: __('Details'),
      tabContent: (
        <ContentDetailInfo contentDetails={detailInfo} displayMap={displayMap} />
      ),
    },
    {
      key: 2,
      tabHeader: __('Repositories'),
      tabContent: (repositories && repositories.length ?
        <ContentDetailRepositories repositories={repositories} /> :
        __('No repositories to show')
      ),
    },
  ];
};
