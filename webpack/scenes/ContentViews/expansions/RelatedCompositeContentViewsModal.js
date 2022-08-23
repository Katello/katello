import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';
import { Modal, ModalVariant, Button, Flex, FlexItem } from '@patternfly/react-core';
import { TableComposable, Thead, Tbody, Tr, Th, Td } from '@patternfly/react-table';
import { EnterpriseIcon } from '@patternfly/react-icons';
import { urlBuilder } from '../../../__mocks__/foremanReact/common/urlHelpers';

/* eslint-disable react/no-array-index-key */
const RelatedCompositeContentViewsModal = ({
  cvName, cvId, relatedCVCount, relatedCompositeCVs,
}) => {
  const [isOpen, setIsOpen] = useState(false);

  const description = () => (
    <Flex flex={{ default: 'inlineFlex' }}>
      <FlexItem>
        <EnterpriseIcon />
        <b>{` ${cvName}`}</b>
        {__(' content view is used in listed composite content views.')}
      </FlexItem>
    </Flex>
  );

  const handleModalToggle = () => {
    setIsOpen(!isOpen);
  };

  const columns = ['Name'];
  return (
    <>
      <Button ouiaId="related-cv-count" aria-label={`button_${cvId}`} variant="link" isInline onClick={handleModalToggle}>
        {relatedCVCount}
      </Button>
      <Modal
        title={__('Related composite content views')}
        ouiaId="related-composite-cvs"
        variant={ModalVariant.large}
        isOpen={isOpen}
        description={description()}
        onClose={() => {
          setIsOpen(false);
        }}
        appendTo={document.body}
      >
        <TableComposable
          aria-label={`${cvId}_table`}
          ouiaId={`${cvId}_table`}
          variant="compact"
        >
          <Thead>
            <Tr ouiaId="table-header-row">
              {columns.map((column, columnIndex) => (
                <Th key={columnIndex}>{column}</Th>
              ))}
            </Tr>
          </Thead>
          <Tbody>
            {relatedCompositeCVs.map(cv => (
              <Tr key={cv.id} ouiaId={`row-${cv.id}`}>
                <Td key={`${cv.id}_${cv.name}`} dataLabel={columns[cv.id]}>
                  <Link to={`${urlBuilder('content_views', '')}${cv.id}`}>{cv.name}</Link>
                </Td>
              </Tr>
            ))}
          </Tbody>
        </TableComposable>
      </Modal>
    </>
  );
};

export default RelatedCompositeContentViewsModal;

RelatedCompositeContentViewsModal.propTypes = {
  cvName: PropTypes.string.isRequired,
  cvId: PropTypes.number.isRequired,
  relatedCVCount: PropTypes.number.isRequired,
  relatedCompositeCVs: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
};
