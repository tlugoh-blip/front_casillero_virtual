const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const crypto = require('crypto');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// In-memory store: tokenHash -> { email, expiresAt, used }
const store = new Map();

function hashToken(token) {
  return crypto.createHash('sha256').update(token).digest('hex');
}

app.post('/usuario/forgot', (req, res) => {
  const { email } = req.body || {};
  if (!email || typeof email !== 'string') return res.status(400).json({ error: 'missing_email' });
  // Validate email simple
  const emailRegex = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;
  if (!emailRegex.test(email)) return res.status(400).json({ error: 'invalid_email' });

  // Generate token
  const token = crypto.randomBytes(20).toString('hex');
  const tokenHash = hashToken(token);
  const expiresAt = Date.now() + 60 * 60 * 1000; // 1 hour

  store.set(tokenHash, { email, expiresAt, used: false });

  // Simulate sending email by printing the reset URL to console
  const resetLink = `https://example.com/reset?token=${token}`;
  console.log(`--- Mock mail to: ${email} ---`);
  console.log(`Reset link: ${resetLink}`);
  console.log('--- end mock mail ---');

  // For privacy, always return generic success
  return res.status(200).json({ message: 'if_exists_email_sent' });
});

app.post('/usuario/reset', (req, res) => {
  const { token, password } = req.body || {};
  if (!token || !password) return res.status(400).json({ error: 'missing_token_or_password' });

  const tokenHash = hashToken(token);
  const record = store.get(tokenHash);
  if (!record) return res.status(401).json({ error: 'invalid_token' });
  if (record.used) return res.status(401).json({ error: 'invalid_token' });
  if (Date.now() > record.expiresAt) return res.status(410).json({ error: 'token_expired' });

  // Simulate updating password for the email
  console.log(`Password change for ${record.email}: new password set (mock).`);
  record.used = true;
  store.set(tokenHash, record);

  return res.status(200).json({ message: 'password_reset_success' });
});

const PORT = 8620;
app.listen(PORT, () => {
  console.log(`Mock auth server listening on http://localhost:${PORT}`);
});

