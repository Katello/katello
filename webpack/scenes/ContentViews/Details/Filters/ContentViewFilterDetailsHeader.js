import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useHistory } from 'react-router-dom';
import { head } from 'lodash';
import {
  Split,
  SplitItem,
  Grid,
  GridItem,
  TextContent,
  Text,
  TextVariants,
  Label,
  Dropdown,
  DropdownItem,
  KebabToggle,
  DropdownPosition,
  Flex,
  FlexItem,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { useDispatch } from 'react-redux';
import {
  getCVFilterDetails,
  editCVFilter,
  deleteContentViewFilter,
} from '../ContentViewDetailActions';
import AffectedRepositorySelection from './AffectedRepositories/AffectedRepositorySelection';
import RepoIcon from '../Repositories/RepoIcon';
import { repoType } from '../../../../utils/helpers';
import { hasPermission } from '../../helpers';
import { typeName } from './ContentType';
import ActionableDetail from '../../../../components/ActionableDetail';
import { ArtifactsWithNoErrataRenderer } from './ArtifactsWithNoErrata';

const ContentViewFilterDetailsHeader = ({
  cvId, filterId, filterDetails, setShowAffectedRepos, details,
}) => {
  const dispatch = useDispatch();
  const { push } = useHistory();
  const [currentAttribute, setCurrentAttribute] = useState('');
  const [loading, setLoading] = useState(false);
  const [dropDownOpen, setDropdownOpen] = useState(false);
  const {
    type, name, inclusion, description, rules,
  } = filterDetails;
  const { permissions } = details;
  const errataByDate = !!(type === 'erratum' && head(rules)?.types);
  const repositoryType = repoType(type);

  const displayedType = () => typeName(type, errataByDate);

  const onEdit = async (val, attribute) => {
    if (val === filterDetails[attribute]) return;
    setLoading(true);
    await dispatch(editCVFilter(
      filterId,
      { [attribute]: val },
      () => {
        setLoading(false);
        dispatch(getCVFilterDetails(cvId, filterId));
      },
      () => setLoading(false),
    ));
  };

  const dropDownItems = [
    <DropdownItem
      key="delete"
      ouiaId="cv-filter-delete"
      onClick={() => {
        dispatch(deleteContentViewFilter(filterId, () => {
          push(`/content_views/${cvId}#/filters/`);
        }));
      }}
    >
      {__('Delete')}
    </DropdownItem>,
  ];

  const showArtifactsWithNoErrata = (type === 'rpm' || type === 'modulemd');
  return (
    <Grid className="margin-0-24">
      <GridItem span={9}>
        <TextContent>
          <ActionableDetail
            key={name} // This fixes a render issue with the initial value
            attribute="name"
            loading={loading && currentAttribute === 'name'}
            placeholder={__('Enter a name')}
            onEdit={onEdit}
            disabled={!hasPermission(permissions, 'edit_content_views')}
            value={name}
            component={TextVariants.h2}
            currentAttribute={currentAttribute}
            setCurrentAttribute={setCurrentAttribute}
          />
        </TextContent>
        {showArtifactsWithNoErrata &&
          <TextContent style={{ padding: '12px 0 12px' }}>
            <ArtifactsWithNoErrataRenderer
              filterDetails={filterDetails}
            />
          </TextContent>
        }
        <TextContent style={{ padding: '12px 0 12px' }}>
          <ActionableDetail
            key={description} // This fixes a render issue with the initial value
            textArea
            attribute="description"
            loading={loading && currentAttribute === 'description'}
            placeholder={__('No description')}
            onEdit={onEdit}
            disabled={!hasPermission(permissions, 'edit_content_views')}
            value={description}
            currentAttribute={currentAttribute}
            setCurrentAttribute={setCurrentAttribute}
          />
        </TextContent>
      </GridItem>
      <GridItem span={3} style={{ float: 'right' }}>
        <Flex justifyContent={{ lg: 'justifyContentFlexEnd', sm: 'justifyContentFlexStart' }}>
          <FlexItem>
            <AffectedRepositorySelection
              cvId={cvId}
              filterId={filterId}
              setShowAffectedRepos={setShowAffectedRepos}
              disabled={!hasPermission(permissions, 'edit_content_views')}
            />
          </FlexItem>
          <FlexItem>
            <Dropdown
              ouiaId="cv-filter-actions-kebab"
              position={DropdownPosition.right}
              style={{ marginLeft: 'auto' }}
              toggle={<KebabToggle onToggle={setDropdownOpen} id="toggle-dropdown" />}
              isOpen={dropDownOpen}
              isPlain
              dropdownItems={dropDownItems}
            />
          </FlexItem>
        </Flex>
      </GridItem>
      <GridItem span={10}>
        <Split hasGutter style={{ alignItems: 'baseline' }}>
          <SplitItem>
            <Label color="blue">{inclusion ? __('Include') : __('Exclude')}</Label>
          </SplitItem>
          <SplitItem>
            <RepoIcon type={repositoryType} />
          </SplitItem>
          <SplitItem>
            <Text ouiaId={`text-${displayedType()}`} component={TextVariants.p}>
              {displayedType()}
            </Text>
          </SplitItem>
        </Split>
      </GridItem>
    </Grid>
  );
};

ContentViewFilterDetailsHeader.propTypes = {
  cvId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  filterId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  filterDetails: PropTypes.shape({
    name: PropTypes.string,
    type: PropTypes.string,
    inclusion: PropTypes.bool,
    description: PropTypes.string,
    rules: PropTypes.arrayOf(PropTypes.shape({ types: PropTypes.arrayOf(PropTypes.string) })),
  }).isRequired,
  setShowAffectedRepos: PropTypes.func.isRequired,
  details: PropTypes.shape({
    permissions: PropTypes.shape({}),
  }).isRequired,
};

ContentViewFilterDetailsHeader.defaultProps = {
  cvId: '',
  filterId: '',
};

export default ContentViewFilterDetailsHeader;
