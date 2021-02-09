import React, { FC } from 'react';
import styled from 'styled-components';

const Table = styled.table`
    border-collapse: collapse;
    width: 100%;
    max-width: 1200px;
`;

const TD = styled.td`
    border: 1px solid #dddddd;
    text-align: left;
    padding: 8px;
`;

const TH = styled.th`
    border: 1px solid #dddddd;
    text-align: left;
    padding: 8px;
`;

const Title = styled.h2`
    font-size: 1.5em;
    color: palevioletred;
`;

const PaginationContainer = styled.div`
`;

const Button = styled.button`
  color: royalblue;
  font-size: 1em;
  margin: 1em;
  padding: 0.25em 1em;
  border: 2px solid royalblue;
  border-radius: 3px;
  cursor: pointer;
`;

type $Row = Array<{ id: string; displayValue: string }>;

type $TableView = {
    title: string;
    columns: Array<string>;
    data: Array<$Row>;
    loading: boolean;
    currentPage?: number;
    hasNext?: boolean;
    hasPrev?: boolean;
    onPrevClick?: () => void;
    onNextClick?: () => void;
};

const dataComponent = (row: $Row) => {
    const key = row.reduce((acc, c) => acc.concat(c.id), '');
    return <tr key={key}>
        {row.map(r => <TD key={r.id}>{r.displayValue}</TD>)}
    </tr>;
};

const TableView: FC<$TableView> = (props) => {

    if (props.loading) return <h2>Loading...</h2>;

    return <>
        <Title>{props.title}</Title>
        <PaginationContainer>
            { props.hasPrev && props.onPrevClick ? <Button onClick={props.onPrevClick}> &lt; </Button> : null}
            { props.currentPage ? <span>Page: {props.currentPage}</span> : null}
            { props.hasNext && props.onNextClick ? <Button onClick={props.onNextClick}> &gt; </Button> : null}
        </PaginationContainer>
        <Table>
            <tbody>
            <tr>
                {props.columns.map(h => <TH key={h}>{h}</TH>)}
            </tr>
            {props.data?.map(p => dataComponent(p))}
            </tbody>
        </Table>
    </>;
};

export default TableView;
