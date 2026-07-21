const { createClient } = require('@supabase/supabase-js');
const axios = require('axios');

const supabaseUrl = 'https://gauoglgismrwxtwsdaci.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdhdW9nbGdpc21yd3h0d3NkYWNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ0NTY0OTksImV4cCI6MjEwMDAzMjQ5OX0.0NwaVZPSIEeuJ3_O7pxnex2H2yFL45IYzP9SP7ni-rI';
const backendUrl = 'http://127.0.0.1:3000';
const testEmail = `test_${Date.now()}@example.com`;
const testPassword = 'TestPass123!';

async function testFullFlow() {
  try {
    console.log('Testing full login flow...\n');

    // 1. Sign up with Supabase
    const client = createClient(supabaseUrl, supabaseKey);
    console.log('1️⃣ Creating test account...');
    const { data: signupData, error: signupError } = await client.auth.signUp({
      email: testEmail,
      password: testPassword,
      data: { username: 'TestUser' }
    });

    if (signupError) {
      console.error('❌ Signup failed:', signupError.message);
      return;
    }
    console.log('✓ Account created:', testEmail);
    const userId = signupData.user.id;

    // 2. Login with Supabase
    console.log('\n2️⃣ Logging in...');
    const { data: loginData, error: loginError } = await client.auth.signInWithPassword({
      email: testEmail,
      password: testPassword,
    });

    if (loginError) {
      console.error('❌ Login failed:', loginError.message);
      return;
    }
    const token = loginData.session.access_token;
    console.log('✓ Login successful');
    console.log('✓ Token received:', token.substring(0, 50) + '...');

    // 3. Test backend /auth/me endpoint
    console.log('\n3️⃣ Testing backend authentication...');
    try {
      const response = await axios.get(`${backendUrl}/auth/me`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });
      console.log('✓ Backend authentication successful!');
      console.log('✓ User profile:', JSON.stringify(response.data, null, 2));
    } catch (error) {
      if (error.response?.status === 401) {
        console.error('❌ Backend rejected token (401 Unauthorized)');
        console.error('Error:', error.response.data);
      } else {
        console.error('❌ Backend error:', error.message);
      }
      return;
    }

    console.log('\n✅ Full login flow test PASSED!');
    console.log('\nSummary:');
    console.log('- Supabase signup: ✓');
    console.log('- Supabase login: ✓');
    console.log('- Backend authentication: ✓');
    console.log('\nYour login system is working correctly!');

  } catch (error) {
    console.error('Fatal error:', error.message);
  }
}

testFullFlow();
