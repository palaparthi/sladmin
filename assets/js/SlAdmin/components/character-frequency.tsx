import React, { FC } from 'react';
import { gql, useQuery } from '@apollo/client';
import TableView from '../common/table-view';
import { $CharacterFrequency } from '../types/nodes';

const GET_FREQUENCY = gql`
    query PeopleCharacterFrequency {
        peopleCharacterFrequency {
            letter
            count
        }
    }
`;

const CharacterFrequency: FC = () => {
    const { loading, data } = useQuery(GET_FREQUENCY);

    const tableData = data?.peopleCharacterFrequency?.map((c: $CharacterFrequency) => (
        [
            { id: `${c.letter}`, displayValue: c.letter },
            { id: `${c.letter}_${c.count}`, displayValue: c.count }
        ])) || [];

    return <TableView
        title={'Character Frequency of Emails'}
        columns={['Character', 'Count']}
        data={tableData}
        loading={loading}
    />;
};

export default CharacterFrequency;