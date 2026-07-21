const { createClient } = require('@supabase/supabase-js');
const http = require('http');

const supabaseUrl = 'https://gauoglgismrwxtwsdaci.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdhdW9nbGdpc21yd3h0d3NkYWNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ0NTY0OTksImV4cCI6MjEwMDAzMjQ5OX0.0NwaVZPSIEeuJ3_O7pxnex2H2yFL45IYzP9SP7ni-rI';

async function test() {
  const client = createClient(supabaseUrl, supabaseKey);
  const testEmail = `test_${Date.now()}@example.com`;
  const testPassword = 'TestPass123!';

  // Signup
  const { data, error } = await client.auth.signUp({
    email: testEmail,
    password: testPassword,
  });

  if (error) {
    console.error('Signup failed:', error.message);
    return;
  }

  const token = data?.session?.access_token;
  console.log('Got token from Supabase:', token.substring(0, 50) + '...');
  console.log('\n=== Testing /auth/me endpoint ===');

  return new Promise((resolve) => {
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: '/auth/me',
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    };

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        console.log(`Status: ${res.statusCode}`);
        console.log('Response:', body);
        resolve();
      });
    });

    req.on('error', (e) => {
      console.error('Request failed:', e.message);
      resolve();
    });

    req.end();
  });
}

test();
