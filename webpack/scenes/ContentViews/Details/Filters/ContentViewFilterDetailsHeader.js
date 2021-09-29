import React from 'react';
import PropTypes from 'prop-types';
import { capitalize, head } from 'lodash';
import { Split, SplitItem, GridItem, TextContent, Text, TextVariants, Label } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import AffectedRepositorySelection from './AffectedRepositories/AffectedRepositorySelection';
import RepoIcon from '../Repositories/RepoIcon';
import { repoType } from '../../../../utils/helpers';

const ContentViewFilterDetailsHeader = ({
  cvId, filterId, details, setShowAffectedRepos,
}) => {
  const {
    type, name, inclusion, description, rules,
  } = details;
  const errataByDate = !!(type === 'erratum' && head(rules)?.types);
  const repositoryType = repoType(type);
  const displayedType = () => {
    if (errataByDate) return __('Errata - by date range');
    if (type) return capitalize(type.replace(/_/g, ' '));
    return '';
  };

  return (
    <>
      <GridItem span={9}>
        <TextContent>
          <Text component={TextVariants.h2}>{name}</Text>
        </TextContent>
      </GridItem>
      <GridItem span={3} style={{ float: 'right' }}>
        <AffectedRepositorySelection
          cvId={cvId}
          filterId={filterId}
          setShowAffectedRepos={setShowAffectedRepos}
        />
      </GridItem>
      <GridItem span={10}>
        <Split hasGutter>
          <SplitItem>
            <Label color="blue">{inclusion ? __('Include') : __('Exclude') }</Label>
          </SplitItem>
          <SplitItem>
            <RepoIcon type={repositoryType} />
          </SplitItem>
          <SplitItem>
            <Text component={TextVariants.p}>
              {displayedType()}
            </Text>
          </SplitItem>
        </Split>
      </GridItem>
      <GridItem span={12}>
        <TextContent>
          <Text component={TextVariants.p}>{description}</Text>
        </TextContent>
      </GridItem>
    </>
  );
};

ContentViewFilterDetailsHeader.propTypes = {
  cvId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  filterId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  details: PropTypes.shape({
    name: PropTypes.string,
    type: PropTypes.string,
    inclusion: PropTypes.bool,
    description: PropTypes.string,
    rules: PropTypes.arrayOf(PropTypes.shape({ types: PropTypes.arrayOf(PropTypes.string) })),
  }).isRequired,
  setShowAffectedRepos: PropTypes.func.isRequired,
};

ContentViewFilterDetailsHeader.defaultProps = {
  cvId: '',
  filterId: '',
};

export default ContentViewFilterDetailsHeader;
