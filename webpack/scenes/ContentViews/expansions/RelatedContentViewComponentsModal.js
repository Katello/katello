import React, { useCallback, useState } from 'react';
import { useSelector } from 'react-redux';
import { Link } from 'react-router-dom';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import PropTypes from 'prop-types';
import { Grid, GridItem, Modal, ModalVariant, Button, Flex, FlexItem } from '@patternfly/react-core';
import { TableVariant, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import { RegistryIcon } from '@patternfly/react-icons';
import TableWrapper from '../../../components/Table/TableWrapper';
import { getContentViewComponents } from '../Details/ContentViewDetailActions';
import {
  selectCVComponents,
  selectCVComponentsError,
  selectCVComponentsStatus,
} from '../Details/ContentViewDetailSelectors';

const RelatedContentViewsModal = ({ cvName, cvId, relatedCVCount }) => {
  const response = useSelector(state => selectCVComponents(state, cvId));
  const status = useSelector(state => selectCVComponentsStatus(state, cvId));
  const error = useSelector(state => selectCVComponentsError(state, cvId));
  const { results, ...metadata } = response;

  const [isOpen, setIsOpen] = useState(false);
  const [searchQuery, updateSearchQuery] = useState('');

  const description = () => (
    <Flex flex={{ default: 'inlineFlex' }}>
      <FlexItem>
        <RegistryIcon />
        <b>{` ${cvName}`}</b>
        {__(' content view is used in listed content views. For more information, ')}
        <Link to={urlBuilder(`content_views/${cvId}#/contentviews`, '')}>
          {__('view content view tabs.')}
        </Link>
      </FlexItem>
    </Flex>
  );

  const handleModalToggle = () => {
    setIsOpen(!isOpen);
  };

  return (
    <>
      <Button ouiaId="related-cv-count" aria-label={`button_${cvId}`} variant="link" isInline onClick={handleModalToggle}>
        {relatedCVCount}
      </Button>
      <Grid>
        <GridItem span={12}>
          <Modal
            title={__('Related content views')}
            ouiaId="related-cvs"
            variant={ModalVariant.medium}
            isOpen={isOpen}
            description={description()}
            onClose={() => {
              setIsOpen(false);
            }}
            appendTo={document.body}
          >
            <TableWrapper
              {...{
                metadata,
                searchQuery,
                updateSearchQuery,
                error,
                status,
              }}
              ouiaId="related-content-view-components-table"
              fetchItems={useCallback(params => getContentViewComponents(cvId, params, 'Added'), [cvId])}
              variant={TableVariant.compact}
              autocompleteEndpoint="/katello/api/v2/content_views"
              emptyContentTitle={__('You currently don\'t have any related content views.')}
              emptySearchTitle={__('No matching content views found')}
              emptyContentBody={__('Related content views will appear here when created.')}
              emptySearchBody={__('Try changing your search settings.')}
            >
              <Thead>
                <Tr ouiaId="column-headers">
                  <Th key="name_col">{__('Name')}</Th>
                </Tr>
              </Thead>
              <Tbody>
                {results?.map(details => (
                  <Tr key={`${details.content_view.id}`} ouiaId={`${details.content_view.id}`}>
                    <Td>
                      <Link to={urlBuilder(`content_views/${details.content_view.id}`, '')}>{details.content_view.name}</Link>
                    </Td>
                  </Tr>
                ))
                }
              </Tbody>
            </TableWrapper>
          </Modal>
        </GridItem>
      </Grid>
    </>
  );
};

export default RelatedContentViewsModal;

RelatedContentViewsModal.propTypes = {
  cvName: PropTypes.string.isRequired,
  cvId: PropTypes.number.isRequired,
  relatedCVCount: PropTypes.number.isRequired,
};
