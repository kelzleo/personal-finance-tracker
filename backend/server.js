const express = require('express');
const { router: transactionsRouter } = require('./routes/transactions');
const summaryRouter = require('./routes/summary');

const app = express();
app.use(express.json());

app.use('/transactions', transactionsRouter);
app.use('/summary', summaryRouter);

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});