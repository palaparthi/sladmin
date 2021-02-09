import React, { useState } from 'react';
import styled from 'styled-components';
import ListPeople from './components/list-people';
import CharacterFrequency from './components/character-frequency';
import DuplicatePeople from './components/duplicate-people';

const Title = styled.h1`
    font-size: 3em;
    text-align: center;
    color: palevioletred;
`;

const MainContainer = styled.div`
    padding: 10px;
    display: flex;
    flex-direction: column;
    align-items: center;
`;

const Button = styled.button`
  color: palevioletred;
  font-size: 1em;
  margin: 1em;
  padding: 0.25em 1em;
  border: 2px solid palevioletred;
  border-radius: 3px;
  cursor: pointer;
`;

type $ViewType = 'LIST' | 'FREQUENCY' | 'DUPLICATES';

const Home = () => {
    const [view, setView] = useState<$ViewType>('LIST');
    return (
        <MainContainer>
            <Title>SalesLoft Admin</Title>
            <div>
                <Button disabled={view === 'LIST'} onClick={() => setView('LIST')}>People</Button>
                <Button disabled={view === 'FREQUENCY'} onClick={() => setView('FREQUENCY')}>Frequency Count of
                    Characters in Emails</Button>
                <Button disabled={view === 'DUPLICATES'} onClick={() => setView('DUPLICATES')}>Possible
                    Duplicates</Button>
            </div>
            {view === 'LIST' ? <ListPeople/> : null}
            {view === 'FREQUENCY' ? <CharacterFrequency/> : null}
            {view === 'DUPLICATES' ? <DuplicatePeople/> : null}
        </MainContainer>
    );
};

export default Home;
