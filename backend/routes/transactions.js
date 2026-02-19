const express = require('express');
const router = express.Router();

let transactions = [];
let nextId = 1;

function validate(body) {
  const errors = [];
  if (!body.title || typeof body.title !== 'string' || body.title.trim() === '') {
    errors.push('title is required and must be a string');
  }
  if (body.amount === undefined || typeof body.amount !== 'number' || body.amount <= 0) {
    errors.push('amount is required and must be a positive number');
  }
  if (!body.type || !['income', 'expense'].includes(body.type)) {
    errors.push('type is required and must be income or expense');
  }
  if (!body.category || typeof body.category !== 'string' || body.category.trim() === '') {
    errors.push('category is required and must be a string');
  }
  if (!body.date || isNaN(Date.parse(body.date))) {
    errors.push('date is required and must be a valid ISO string');
  }
  return errors;
}

router.get('/', (req, res) => {
  res.json(transactions);
});

router.post('/', (req, res) => {
  const errors = validate(req.body);
  if (errors.length > 0) {
    return res.status(400).json({ errors });
  }

  const transaction = {
    id: nextId++,
    title: req.body.title.trim(),
    amount: req.body.amount,
    type: req.body.type,
    category: req.body.category.trim(),
    date: req.body.date,
    note: req.body.note || null,
  };

  transactions.push(transaction);
  res.status(201).json(transaction);
});

router.get('/:id', (req, res) => {
  const transaction = transactions.find((t) => t.id === parseInt(req.params.id));
  if (!transaction) {
    return res.status(404).json({ error: 'Transaction not found' });
  }
  res.json(transaction);
});

router.patch('/:id', (req, res) => {
  const index = transactions.findIndex((t) => t.id === parseInt(req.params.id));
  if (index === -1) {
    return res.status(404).json({ error: 'Transaction not found' });
  }

  const updated = { ...transactions[index], ...req.body };
  transactions[index] = updated;
  res.json(updated);
});

router.delete('/:id', (req, res) => {
  const index = transactions.findIndex((t) => t.id === parseInt(req.params.id));
  if (index === -1) {
    return res.status(404).json({ error: 'Transaction not found' });
  }

  transactions.splice(index, 1);
  res.json({ message: 'Transaction deleted successfully' });
});

module.exports = { router, getTransactions: () => transactions };