const express = require('express');
const _ = require('lodash');
const app = express();

app.use(express.static('public'));
app.get('/api/info', (req, res) => {
  res.json(_.merge({ app: 'sample-app', status: 'ok' }, { time: new Date().toISOString() }));
});
app.listen(3000, () => console.log('sample-app listening on :3000'));
