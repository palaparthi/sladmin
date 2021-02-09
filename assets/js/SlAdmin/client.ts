import { ApolloClient, InMemoryCache } from '@apollo/client';

const client = new ApolloClient({
    uri: 'http://localhost:4040/api',
    cache: new InMemoryCache({
        typePolicies: {
            CharacterFrequency: {
                // for CharacterFrequency consider letter as the id
                keyFields: ['letter']
            }
        }
    })
});

export default client;
