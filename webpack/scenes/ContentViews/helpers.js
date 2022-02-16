import { translate as __ } from 'foremanReact/common/I18n';

export const dependenciesHelpText = __('This will solve RPM and module stream dependencies on every publish of this content view. ' +
  'Dependency solving significantly increases publish time (publishes can take over three times as long) ' +
  'and filters will be ignored when adding packages to solve dependencies. ' +
  'Also, certain scenarios involving errata may still cause dependency errors.');

export const autoPublishHelpText = __('Automatically publish a new version of the composite content view whenever one of its content views is published. ' +
  'Autopublish will only happen for component views that use the \'Always use latest version\' option.');

export const importOnlyHelpText = __('Designate whether this content view is for importing from an upstream server. ' +
  'Import-only content views cannot be published directly.');

export const generatedContentViewHelpText = __('This content view is generated for importing or exporting content view versions. ' +
  'Generated content views cannot be published directly and can only be updated via import/export process.');

export const hasPermission = (permissions, perm) => permissions && permissions[perm];
