import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { useSelector } from 'react-redux';
import {
  Grid, GridItem, TextContent, Text, TextVariants,
  Select, SelectOption, SelectVariant, Flex, FlexItem,
} from '@patternfly/react-core';
import { selectCVDetails } from '../../ContentViewDetailSelectors';
import { HelpToolTip } from '../../../Create/ContentViewFormComponents';

const CVVersionCompareHeader = ({
  versionOne, versionTwo, cvId, setVersionOne, setVersionTwo, selectedViewBy, setSelectedViewBy,
}) => {
  const toolTipContent = 'Compare the content of any two versions of this content view.';
  const response = useSelector(state => selectCVDetails(state, cvId));
  const { versions } = response;
  const [isOpenSelectVersionOne, setIsOpenSelectVersionOne] = useState(false);
  const [isOpenSelectVersionTwo, setIsOpenSelectVersionTwo] = useState(false);
  const [isOpenSelectViewBy, setIsOpenSelectViewBy] = useState(false);
  const viewBySelectionOptions = ['All', 'Different', 'Same'];

  const clearSelectionVersionOne = () => {
    setVersionOne(null);
    setIsOpenSelectVersionOne(false);
  };
  const clearSelectionVersionTwo = () => {
    setVersionTwo(null);
    setIsOpenSelectVersionTwo(false);
  };

  const clearSelectionViewBy = () => {
    setSelectedViewBy('');
    setIsOpenSelectViewBy(false);
  };
  const onSelectVersionOne = (_event, selection, isPlaceholder) => {
    if (isPlaceholder) {
      clearSelectionVersionOne();
    } else {
      setVersionOne(selection);
      setIsOpenSelectVersionOne(false);
    }
  };

  const onSelectVersionTwo = (_event, selection, isPlaceholder) => {
    if (isPlaceholder) {
      clearSelectionVersionTwo();
    } else {
      setVersionTwo(selection);
      setIsOpenSelectVersionTwo(false);
    }
  };

  const onSelectViewBy = (_event, selection, isPlaceholder) => {
    if (isPlaceholder) {
      clearSelectionViewBy();
    } else {
      setSelectedViewBy(selection);
      setIsOpenSelectViewBy(false);
    }
  };

  const filteredVersions = selectedVersion =>
    versions?.filter(result => Number(result.version) !== Number(selectedVersion));
  const filteredVersionsFirstSelect = versions?.filter(result =>
    Number(result.version) !== Number(versionTwo));
  const filteredVersionsSecondSelect = versions?.filter(result =>
    Number(result.version) !== Number(versionOne));
  const selectionOptionsViewBy = viewBySelectionOptions.map(option => (
    <SelectOption
      key={option}
      value={option}
      aria-label={`View by ${option}`}
    >
      {__(`${option}`)}
    </SelectOption>
  ));
  return (
    <Grid hasGutter style={{ margin: '0 24px' }}>
      <GridItem span={12} style={{ display: 'flex' }}>
        <TextContent>
          <Text ouiaId="cv-version-compare-button" component={TextVariants.h2}>{__('Compare')}</Text>
        </TextContent>
        <HelpToolTip className="cvv-spaced-tooltip" tooltip={toolTipContent} />
      </GridItem>
      <GridItem span={12}>
        <Flex>
          <FlexItem style={{ marginRight: '60px' }}>
            <Flex direction={{ default: 'column' }}>
              <h3><b>{__('Versions to compare')}</b></h3>
              <FlexItem>
                <Flex>
                  <FlexItem>
                    <Select
                      style={{ marginRight: '10px' }}
                      variant={SelectVariant.single}
                      placeholderText={__('Select an option')}
                      aria-label="Select version one"
                      ouiaId="select-version-one"
                      onToggle={setIsOpenSelectVersionOne}
                      onSelect={onSelectVersionOne}
                      selections={versionOne}
                      isOpen={isOpenSelectVersionOne}
                      isDisabled={!filteredVersionsFirstSelect?.length}
                    >
                      {filteredVersions(versionTwo)?.map(({ version }) => (
                        <SelectOption
                          key={version}
                          value={version}
                        >
                          {__('Version ')}{version}
                        </SelectOption>
                      ))}
                    </Select>
                  </FlexItem>
                  <FlexItem>
                    <TextContent style={{ marginRight: '10px' }}>
                      <Text ouiaId="to-text" component={TextVariants.h4}>{__('to')}</Text>
                    </TextContent>
                  </FlexItem>
                  <FlexItem>
                    <Select
                      variant={SelectVariant.single}
                      placeholderText="Select an option"
                      aria-label="Select version two"
                      ouiaId="select-version-two"
                      onToggle={setIsOpenSelectVersionTwo}
                      onSelect={onSelectVersionTwo}
                      selections={versionTwo}
                      isOpen={isOpenSelectVersionTwo}
                      isDisabled={!filteredVersionsSecondSelect?.length}
                    >
                      {filteredVersions(versionOne)?.map(({ version }) => (
                        <SelectOption
                          key={version}
                          value={version}
                        >
                          {__('Version ')}{version}
                        </SelectOption>
                      ))}
                    </Select>
                  </FlexItem>
                </Flex>
              </FlexItem>
            </Flex>
          </FlexItem >
          <FlexItem className="border-left" style={{ paddingLeft: '60px' }}>
            <Flex direction={{ default: 'column' }}>
              <h3><b>{__('View by')}</b></h3>
              <FlexItem>
                <Select
                  style={{ marginRight: '10px' }}
                  variant={SelectVariant.single}
                  placeholderText="Select an option"
                  aria-label="Select view by"
                  ouiaId="select-view-by"
                  onToggle={setIsOpenSelectViewBy}
                  onSelect={onSelectViewBy}
                  selections={selectedViewBy}
                  isOpen={isOpenSelectViewBy}
                  isDisabled={!(filteredVersionsFirstSelect?.length
                    && filteredVersionsSecondSelect?.length)}
                >
                  {selectionOptionsViewBy}
                </Select>
              </FlexItem>
            </Flex>
          </FlexItem >
        </Flex >
      </GridItem>
    </Grid>
  );
};

CVVersionCompareHeader.propTypes = {
  versionOne: PropTypes.string.isRequired,
  versionTwo: PropTypes.string.isRequired,
  cvId: PropTypes.number.isRequired,
  setVersionOne: PropTypes.func.isRequired,
  setVersionTwo: PropTypes.func.isRequired,
  selectedViewBy: PropTypes.string.isRequired,
  setSelectedViewBy: PropTypes.func.isRequired,
};
export default CVVersionCompareHeader;
