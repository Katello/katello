import React, { useEffect } from 'react';
import { useParams, useHistory, useLocation } from 'react-router-dom';
import { useSelector, useDispatch, shallowEqual } from 'react-redux';
import {
  Breadcrumb,
  BreadcrumbItem,
  Title,
  PageSection,
  Grid,
  GridItem,
  TextContent,
  Text,
  TextVariants,
  ClipboardCopy,
  Label,
  Flex,
  FlexItem,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import Loading from 'foremanReact/components/Loading';
import LongDateTime from 'foremanReact/components/common/dates/LongDateTime';
import EmptyStateMessage from '../../../../components/Table/EmptyStateMessage';
import {
  getManifest,
  getShortDigest,
  formatManifestType,
} from '../../containerImagesHelpers';
import getDockerTagDetails from './ManifestDetailsActions';
import {
  selectDockerTagDetails,
  selectDockerTagDetailStatus,
  selectDockerTagDetailError,
} from './ManifestDetailsSelectors';

const ManifestDetails = () => {
  const { id } = useParams();
  const tagId = Number(id);
  const history = useHistory();
  const location = useLocation();
  const dispatch = useDispatch();

  const searchParams = new URLSearchParams(location.search);
  const manifestId = searchParams.get('manifest');

  useEffect(() => {
    dispatch(getDockerTagDetails(tagId));
  }, [dispatch, tagId]);

  const manifestData = useSelector(state =>
    selectDockerTagDetails(state, tagId), shallowEqual) || {};
  const status = useSelector(state =>
    selectDockerTagDetailStatus(state, tagId));
  const error = useSelector(state =>
    selectDockerTagDetailError(state, tagId));

  const getDisplayManifest = () => {
    const parentManifest = getManifest(manifestData);

    if (!manifestId || !parentManifest) {
      return parentManifest;
    }

    if (parentManifest.manifest_type === 'list' && parentManifest.manifests) {
      const childManifestId = parseInt(manifestId, 10);
      return parentManifest.manifests.find(m => m.id === childManifestId);
    }

    return parentManifest;
  };

  if (status === STATUS.PENDING) {
    return <Loading />;
  }

  if (status === STATUS.ERROR) {
    return <EmptyStateMessage error={error} />;
  }

  const manifest = getDisplayManifest();
  const digest = manifest?.digest || 'N/A';
  const shortDigest = getShortDigest(digest);
  const manifestType = formatManifestType(manifest);

  // Filter to show only library repositories
  const libraryRepositories = manifestData.repositories?.filter(repo =>
    repo.library_instance) || [];

  const labels = manifest?.labels || {};
  const labelKeys = Object.keys(labels);

  return (
    <PageSection variant="light">
      <Grid hasGutter span={12}>
        <GridItem span={12}>
          <Breadcrumb ouiaId="manifest-details-breadcrumb">
            <BreadcrumbItem
              to="/labs/container_images"
              onClick={(e) => {
                e.preventDefault();
                history.push('/labs/container_images');
              }}
            >
              {__('Container images')}
            </BreadcrumbItem>
            <BreadcrumbItem isActive>{shortDigest}</BreadcrumbItem>
          </Breadcrumb>
        </GridItem>

        <GridItem span={12}>
          <Title headingLevel="h1" size="2xl" ouiaId="manifest-details-title">
            {shortDigest}
          </Title>
        </GridItem>

        <GridItem span={12}>
          <Grid hasGutter>
            <GridItem span={6}>
              <TextContent>
                <Text component={TextVariants.h6} ouiaId="manifest-name-label">{__('Name')}</Text>
                <Text ouiaId="manifest-name-value">{manifestData.name || 'N/A'}</Text>
              </TextContent>
            </GridItem>

            <GridItem span={6}>
              <TextContent>
                <Text component={TextVariants.h6} ouiaId="manifest-creation-label">{__('Creation')}</Text>
                {manifest?.created_at ? (
                  <LongDateTime date={manifest.created_at} showRelativeTimeTooltip />
                ) : (
                  <Text ouiaId="manifest-creation-value">N/A</Text>
                )}
              </TextContent>
            </GridItem>

            <GridItem span={6}>
              <TextContent>
                <Text component={TextVariants.h6} ouiaId="manifest-repository-label">{__('Repositories')}</Text>
                <Text ouiaId="manifest-repository-value">
                  {libraryRepositories.length === 0 ? (
                    'N/A'
                  ) : (
                    libraryRepositories.map((repo, index) => (
                      <React.Fragment key={repo.id}>
                        {index > 0 && ', '}
                        <a
                          href={`/products/${repo.product_id}/repositories/${repo.id}`}
                          target="_blank"
                          rel="noopener noreferrer"
                        >
                          {repo.name}
                        </a>
                      </React.Fragment>
                    ))
                  )}
                </Text>
              </TextContent>
            </GridItem>

            <GridItem span={6}>
              <TextContent>
                <Text component={TextVariants.h6} ouiaId="manifest-modified-label">{__('Modified')}</Text>
                {manifest?.updated_at ? (
                  <LongDateTime date={manifest.updated_at} showRelativeTimeTooltip />
                ) : (
                  <Text ouiaId="manifest-modified-value">N/A</Text>
                )}
              </TextContent>
            </GridItem>

            <GridItem span={6}>
              <TextContent>
                <Text component={TextVariants.h6} ouiaId="manifest-digest-label">{__('Digest')}</Text>
                {digest !== 'N/A' ? (
                  <ClipboardCopy variant="inline-compact" clickTip="Copied">
                    {digest}
                  </ClipboardCopy>
                ) : (
                  <Text ouiaId="manifest-digest-value">N/A</Text>
                )}
              </TextContent>
            </GridItem>

            <GridItem span={6}>
              <TextContent>
                <Text component={TextVariants.h6} ouiaId="manifest-type-label">{__('Type')}</Text>
                <Text ouiaId="manifest-type-value">{manifestType}</Text>
              </TextContent>
            </GridItem>

            <GridItem span={6} />

            <GridItem span={6}>
              <TextContent>
                <Text component={TextVariants.h6} ouiaId="manifest-labels-label">{__('Labels')}</Text>
                {labelKeys.length === 0 ? (
                  <div>{__('No labels')}</div>
                ) : (
                  <Flex spaceItems={{ default: 'spaceItemsSm' }} flexWrap={{ default: 'wrap' }}>
                    {labelKeys.map(key => (
                      <FlexItem key={key}>
                        <Label color="grey">
                          {key} = {labels[key]}
                        </Label>
                      </FlexItem>
                    ))}
                  </Flex>
                )}
              </TextContent>
            </GridItem>
          </Grid>
        </GridItem>
      </Grid>
    </PageSection>
  );
};

export default ManifestDetails;
