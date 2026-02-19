const express = require('express');
const router = express.Router();
const { getTransactions } = require('./transactions');

router.get('/', (req, res) => {
  const transactions = getTransactions();

  const totalIncome = transactions
    .filter((t) => t.type === 'income')
    .reduce((sum, t) => sum + t.amount, 0);

  const totalExpenses = transactions
    .filter((t) => t.type === 'expense')
    .reduce((sum, t) => sum + t.amount, 0);

  res.json({
    totalIncome,
    totalExpenses,
    netBalance: totalIncome - totalExpenses,
  });
});

module.exports = router;