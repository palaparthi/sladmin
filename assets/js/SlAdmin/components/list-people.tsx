import React, { useState } from 'react';
import { gql, useQuery } from '@apollo/client';
import TableView from '../common/table-view';
import { $Person } from '../types/nodes';

const LIST_PEOPLE = gql`
    query ListPeople($page: Int!) {
        listPeople(page: $page) {
            people {
                id
                displayName
                emailAddress
                title
            }
            paginationInfo {
                currentPage
                nextPage
                perPage
                prevPage
            }
        }
    }
`;

const ListPeople = () => {
    const [page, setPage] = useState(1);
    const { loading, data } = useQuery(LIST_PEOPLE, { variables: { page }});
    const paginationInfo = data?.listPeople?.paginationInfo;

    const tableData = data?.listPeople?.people?.map((p: $Person) => (
        [
            { id: `${p.id}_${p.displayName}`, displayValue: p.displayName },
            { id: `${p.id}_${p.emailAddress}`, displayValue: p.emailAddress },
            { id: `${p.id}_${p.title}`, displayValue: p.title }
        ])) || [];

    return <TableView
        title={'People'}
        columns={['Name', 'Email Address', 'Job Title']}
        data={tableData}
        loading={loading}
        currentPage={page}
        hasNext={!!paginationInfo?.nextPage}
        onNextClick={() => setPage(page => page + 1)}
        hasPrev={!!paginationInfo?.prevPage}
        onPrevClick={() => setPage(page => page - 1)}
    />;
};

export default ListPeople;
