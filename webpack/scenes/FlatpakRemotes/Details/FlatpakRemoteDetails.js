import React, { useState, useEffect } from 'react';
import { useSelector, useDispatch, shallowEqual } from 'react-redux';
import { useParams } from 'react-router-dom';
import {
  Breadcrumb,
  BreadcrumbItem,
  Title,
  Grid,
  GridItem,
  Text,
  TextContent,
  TextList,
  TextListVariants,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { selectFlatpakRemoteDetails } from './FlatpakRemoteDetailSelectors';
import getFlatpakRemoteDetails, { updateFlatpakRemote } from './FlatpakRemoteDetailActions';
import ActionableDetail from '../../../components/ActionableDetail';
import RemoteRepositoriesTable from './RemoteRepositories/RemoteRepositoriesTable';

export default function FlatpakRemoteDetails() {
  const { id } = useParams();
  const frId = Number(id);
  const dispatch = useDispatch();

  const [currentAttribute, setCurrentAttribute] = useState(null);

  useEffect(() => {
    dispatch(getFlatpakRemoteDetails(frId));
  }, [dispatch, frId]);

  const frDetails = useSelector(state =>
    selectFlatpakRemoteDetails(state, frId), shallowEqual) || {};
  const name = frDetails.name || '';
  const url = frDetails.url || '';

  const onEdit = (val, attribute) => {
    if (val === frDetails[attribute]) return;
    dispatch(updateFlatpakRemote(frId, { [attribute]: val }));
  };

  return (
    <Grid hasGutter span={12} style={{ padding: '24px' }}>
      <GridItem span={12}>
        <Breadcrumb ouiaId="flatpak-remote-breadcrumb">
          <BreadcrumbItem to="/flatpak_remotes">Flatpak remotes</BreadcrumbItem>
          <BreadcrumbItem isActive>{name}</BreadcrumbItem>
        </Breadcrumb>
      </GridItem>

      <GridItem span={12}>
        <Title headingLevel="h1" size="2xl" ouiaId="flatpak-remote-title">{name}</Title>
      </GridItem>

      <GridItem span={12}>
        <TextContent>
          <TextList component={TextListVariants.dl}>
            <ActionableDetail
              key={url}
              label={__('URL:')}
              attribute="url"
              onEdit={onEdit}
              value={url}
              {...{ currentAttribute, setCurrentAttribute }}
            />
          </TextList>
        </TextContent>
      </GridItem>

      <GridItem span={12}>
        <TextContent>
          <Title headingLevel="h2" size="xl" ouiaId="flatpak-remote-subtitle">Remote repositories</Title>
          <Text component="p" ouiaId="flatpak-remote-description" style={{ color: 'gray' }}>
            This is a list of scanned flatpaks.
            Mirroring a scanned flatpak creates a repository in the product of your choice.
            Sync the repository after mirroring it from this remote to distribute its content.
          </Text>
        </TextContent>
      </GridItem>

      <GridItem span={12}>
        <RemoteRepositoriesTable frId={frId} />
      </GridItem>

    </Grid>
  );
}
