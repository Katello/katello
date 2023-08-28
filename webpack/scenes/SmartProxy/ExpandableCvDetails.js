import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import {TableComposable, Thead, Tr, Th, Tbody, Td} from '@patternfly/react-table';
import LongDateTime from 'foremanReact/components/common/dates/LongDateTime';
const ExpandableCvDetails = ({ data }) => {
    const columnHeaders = [
        __('Content View'),
        __('Last published'),
    ];

    return (
        <TableComposable aria-label="content-views">
            <Thead>
                <Tr>
                    {columnHeaders.map(col => (
                        <Th
                            key={col}
                        >
                            {col}
                        </Th>
                    ))}
                </Tr>
            </Thead>
            <Tbody>
                {data.map((cv, rowIndex) => <Tr key={cv.name}>
                    <Td>{cv.label}</Td>
                    <Td><LongDateTime date={cv.last_published} showRelativeTimeTooltip /></Td>
                </Tr>)}
            </Tbody>
        </TableComposable>

    );

};

export default ExpandableCvDetails;