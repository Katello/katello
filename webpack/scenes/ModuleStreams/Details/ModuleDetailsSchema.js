import React from 'react';
import ModuleStreamDetailArtifacts from './ModuleStreamDetailArtifacts';
import ModuleStreamDetailProfiles from './Profiles/ModuleStreamDetailProfiles';
import ContentDetailInfo from '../../../components/Content/Details/ContentDetailInfo';
import ContentDetailRepositories   from '../../../components/Content/Details/ContentDetailRepositories';

export default (detailInfo) => {
  const { repositories, profiles, artifacts } = detailInfo;

  const displayMap = new Map([
    ['name', __('Name')],
    ['summary', __('Summary')],
    ['description', __('Description')],
    ['stream', __('Stream')],
    ['version', __('Version')],
    ['arch', __('Arch')],
    ['context', __('Context')],
    ['uuid', __('UUID')],
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
    {
      tabHeader: __('Profiles'),
      tabContent: (profiles && profiles.length ?
        <ModuleStreamDetailProfiles profiles={profiles} /> :
        __('No profiles to show')
      ),
    },
    {
      tabHeader: __('Artifacts'),
      tabContent: (artifacts && artifacts.length ?
        <ModuleStreamDetailArtifacts artifacts={artifacts} /> :
        __('No artifacts to show')
      ),
    },
  ];
};

