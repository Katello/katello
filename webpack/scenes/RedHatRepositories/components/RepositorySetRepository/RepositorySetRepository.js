import React, { useCallback } from 'react';
import PropTypes from 'prop-types';
import {
  DataListItem,
  DataListItemRow,
  DataListItemCells,
  DataListCell,
  DataListAction,
  Spinner,
  Tooltip,
  Popover,
  Button,
} from '@patternfly/react-core';
import { TimesCircleIcon, PlusCircleIcon, InfoCircleIcon } from '@patternfly/react-icons';

import { sprintf, translate as __ } from 'foremanReact/common/I18n';
import { yStream } from '../RepositorySetRepositoriesHelpers';
import '../../index.scss';

const RepositorySetRepository = ({
  contentId,
  productId,
  displayArch,
  arch,
  releasever,
  type,
  label,
  enabledSearch,
  enabledPagination,
  loading,
  error,
  setRepositoryEnabled,
  loadEnabledRepos,
  enableRepository,
}) => {
  const repoForAction = useCallback(() => ({
    arch,
    productId,
    contentId,
    releasever,
    label,
  }), [arch, productId, contentId, releasever, label]);

  const reloadEnabledRepos = useCallback(() => (
    loadEnabledRepos({
      ...enabledPagination,
      search: enabledSearch,
    }, true)
  ), [loadEnabledRepos, enabledPagination, enabledSearch]);

  const notifyEnabled = useCallback((data) => {
    const repoName = data.output.repository.name;
    window.tfm.toastNotifications.notify({
      message: sprintf(__("Repository '%(repoName)s' has been enabled."), { repoName }),
      type: 'success',
    });
  }, []);

  const reloadAndNotify = useCallback(async (result) => {
    if (result && result.success) {
      await reloadEnabledRepos();
      await setRepositoryEnabled(repoForAction());
      await notifyEnabled(result.data);
    }
  }, [reloadEnabledRepos, setRepositoryEnabled, repoForAction, notifyEnabled]);

  const handleEnableRepository = useCallback(async () => {
    const result = await enableRepository(repoForAction());
    await reloadAndNotify(result);
  }, [enableRepository, repoForAction, reloadAndNotify]);

  const archLabel = displayArch || __('Unspecified');
  const releaseverLabel = releasever || '';

  const yStreamHelpText =
    sprintf(
      __('This repository is not suggested. Please see additional %(anchorBegin)sdocumentation%(anchorEnd)s prior to use.'),
      {
        anchorBegin: '<a href="https://access.redhat.com/articles/1586183">',
        anchorEnd: '</a>',
      },
    );
  // eslint-disable-next-line react/no-danger
  const yStreamHelp = <span dangerouslySetInnerHTML={{ __html: yStreamHelpText }} />;
  const shouldDeemphasize = type !== 'kickstart' && yStream(releaseverLabel);
  const headingId = `repo-${arch || 'unspecified'}-${releasever || 'unspecified'}`;

  const repositoryHeading = (
    <span>
      {archLabel} {releaseverLabel}
      {shouldDeemphasize ? (
        <Popover bodyContent={yStreamHelp}>
          <Button
            variant="plain"
            aria-label={__('Help')}
            ouiaId="ystream-help-button"
            className="ystream-help-button"
          >
            <InfoCircleIcon />
          </Button>
        </Popover>
      ) : null}
    </span>
  );

  const dataListCells = [];

  // Error icon cell (if error exists)
  if (error) {
    const errorCell = (
      <DataListCell key="error-icon" className="repository-cell-icon">
        <div className="list-error-danger">
          <TimesCircleIcon />
        </div>
      </DataListCell>
    );
    dataListCells.push(errorCell);
  }

  // Main content cell
  const contentCell = (
    <DataListCell key="content" className="repository-cell-content">
      <div
        id={headingId}
        className={shouldDeemphasize ? 'deemphasize repository-text-md' : 'repository-name repository-text-md'}
      >
        {repositoryHeading}
      </div>
    </DataListCell>
  );
  dataListCells.push(contentCell);

  return (
    <DataListItem aria-labelledby={headingId} className="list-item-with-divider">
      <DataListItemRow className="repository-item-row">
        <DataListItemCells dataListCells={dataListCells} />
        <DataListAction>
          {loading ? (
            <Spinner size="md" />
          ) : (
            <Tooltip content={__('Enable')} position="bottom">
              <Button
                variant="plain"
                onClick={handleEnableRepository}
                aria-label={__('Enable')}
                ouiaId="enable-repository-button"
                className="enable-repository-button"
              >
                <PlusCircleIcon />
              </Button>
            </Tooltip>
          )}
        </DataListAction>
      </DataListItemRow>
    </DataListItem>
  );
};

RepositorySetRepository.propTypes = {
  contentId: PropTypes.number.isRequired,
  productId: PropTypes.number.isRequired,
  displayArch: PropTypes.string,
  arch: PropTypes.string,
  releasever: PropTypes.string,
  type: PropTypes.string,
  label: PropTypes.string,
  enabledSearch: PropTypes.shape({
    query: PropTypes.string,
    searchList: PropTypes.string,
    // Disabling rule as existing code failed due to an eslint-plugin-react update
    // eslint-disable-next-line react/forbid-prop-types
    filters: PropTypes.array,
  }),
  enabledPagination: PropTypes.shape({
    page: PropTypes.number,
    perPage: PropTypes.number,
  }).isRequired,
  loading: PropTypes.bool,
  error: PropTypes.bool,
  setRepositoryEnabled: PropTypes.func.isRequired,
  loadEnabledRepos: PropTypes.func.isRequired,
  enableRepository: PropTypes.func.isRequired,
};

RepositorySetRepository.defaultProps = {
  type: '',
  label: '',
  releasever: undefined,
  arch: undefined,
  displayArch: undefined,
  enabledSearch: {},
  loading: false,
  error: false,
};

export default RepositorySetRepository;
