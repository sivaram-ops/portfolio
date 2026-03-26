//
// Products
//
db = db.getSiblingDB('users');
db.users.insertMany([
    {name: 'test2', password: 'test2', email: 'test2@test.com'},  
    {name: 'test1', password: 'test1', email: 'test1@test.com'},    
    {name: 'user', password: 'password', email: 'user@me.com'},
    {name: 'stan', password: 'bigbrain', email: 'stan@instana.com'},
    {name: 'phoenix', password: 'phoenix', email: 'phoenix@test.com'},
    {name: 'partner-57', password: 'worktogether', email: 'howdy@partner.com'}
]);

// unique index on the name
db.users.createIndex(
    {name: 1},
    {unique: true}
);

