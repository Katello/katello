import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import ModuleStreamDetailArtifacts from './ModuleStreamDetailArtifacts';
import ModuleStreamDetailProfiles from './Profiles/ModuleStreamDetailProfiles';
import ContentDetailInfo from '../../../components/Content/Details/ContentDetailInfo';
import ContentDetailRepositories from '../../../components/Content/Details/ContentDetailRepositories';

export const displayMap = new Map([
  ['name', __('Name')],
  ['summary', __('Summary')],
  ['description', __('Description')],
  ['stream', __('Stream')],
  ['version', __('Version')],
  ['arch', __('Arch')],
  ['context', __('Context')],
  ['uuid', __('UUID')],
]);

export default (detailInfo) => {
  const { repositories, profiles, artifacts } = detailInfo;

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
    {
      key: 3,
      tabHeader: __('Profiles'),
      tabContent: (profiles && profiles.length ?
        <ModuleStreamDetailProfiles profiles={profiles} /> :
        __('No profiles to show')
      ),
    },
    {
      key: 4,
      tabHeader: __('Artifacts'),
      tabContent: (artifacts && artifacts.length ?
        <ModuleStreamDetailArtifacts artifacts={artifacts} /> :
        __('No artifacts to show')
      ),
    },
  ];
};

