const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://gauoglgismrwxtwsdaci.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdhdW9nbGdpc21yd3h0d3NkYWNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ0NTY0OTksImV4cCI6MjEwMDAzMjQ5OX0.0NwaVZPSIEeuJ3_O7pxnex2H2yFL45IYzP9SP7ni-rI';
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdhdW9nbGdpc21yd3h0d3NkYWNpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ1NjQ5OSwiZXhwIjoyMTAwMDMyNDk5fQ.KpW6jcb1y94jLXJkz0zklkLfS7VE35MCEjt1d_sEQ5Q';

const testEmail = `test_${Date.now()}@example.com`;
const testPassword = 'TestPass123!';

async function test() {
  const client = createClient(supabaseUrl, supabaseKey);
  const adminClient = createClient(supabaseUrl, supabaseServiceKey, {
    auth: { persistSession: false, autoRefreshToken: false }
  });

  console.log('Testing with email:', testEmail);
  console.log('\n=== Signup ===');
  const { data: signupData, error: signupError } = await client.auth.signUp({
    email: testEmail,
    password: testPassword,
  });

  if (signupError) {
    console.error('ERROR:', signupError.message);
    return;
  }

  console.log('✓ Signup success');
  console.log('  User ID:', signupData?.user?.id);
  console.log('  Email confirmed:', signupData?.user?.email_confirmed_at ? 'YES' : 'NO');
  const signupToken = signupData?.session?.access_token;

  console.log('\n=== Login ===');
  const { data: loginData, error: loginError } = await client.auth.signInWithPassword({
    email: testEmail,
    password: testPassword,
  });

  if (loginError) {
    console.error('ERROR:', loginError.message);
    return;
  }

  console.log('✓ Login success');
  const loginToken = loginData?.session?.access_token;

  console.log('\n=== Token validation with admin client ===');
  const { data, error } = await adminClient.auth.admin.getUserById(signupData.user.id);
  if (error) {
    console.error('ERROR:', error.message);
  } else {
    console.log('✓ Admin can access user');
  }
}

test().catch(e => console.error('Fatal:', e.message));
