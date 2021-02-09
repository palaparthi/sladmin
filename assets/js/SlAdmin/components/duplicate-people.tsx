import React, { FC } from 'react';
import { gql, useQuery } from '@apollo/client';
import TableView from '../common/table-view';
import { $Person } from '../types/nodes';

const GET_DUPLICATE_PEOPLE = gql`
    query DuplicatePeople {
        duplicatePeople {
            id
            displayName
            emailAddress
        }
    }
`;

const DuplicatePeople: FC = () => {
    const { loading, data } = useQuery(GET_DUPLICATE_PEOPLE);

    const tableData = data?.duplicatePeople?.map((p: $Person) => (
        [
            { id: `${p.id}_${p.displayName}`, displayValue: p.displayName },
            { id: `${p.id}_${p.emailAddress}`, displayValue: p.emailAddress },

        ])) || [];

    return <TableView
        title={'Possible Duplicate People'}
        columns={['Name', 'Email Address']}
        data={tableData}
        loading={loading}
    />;
};

export default DuplicatePeople;