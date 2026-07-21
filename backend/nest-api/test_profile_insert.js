const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://gauoglgismrwxtwsdaci.supabase.co';
const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdhdW9nbGdpc21yd3h0d3NkYWNpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ1NjQ5OSwiZXhwIjoyMTAwMDMyNDk5fQ.KpW6jcb1y94jLXJkz0zklkLfS7VE35MCEjt1d_sEQ5Q';
const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdhdW9nbGdpc21yd3h0d3NkYWNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ0NTY0OTksImV4cCI6MjEwMDAzMjQ5OX0.0NwaVZPSIEeuJ3_O7pxnex2H2yFL45IYzP9SP7ni-rI';

async function testProfileInsert() {
  console.log('Testing profile insertion...\n');

  // Create user via anon client
  const anonClient = createClient(supabaseUrl, anonKey);
  const testEmail = `test_${Date.now()}@example.com`;
  const { data: signupData, error: signupError } = await anonClient.auth.signUp({
    email: testEmail,
    password: 'TestPass123!',
    data: { username: 'TestUser', avatar_url: null }
  });

  if (signupError) {
    console.error('Signup error:', signupError);
    return;
  }

  const userId = signupData.user.id;
  console.log('Created user:', userId);
  console.log('Email:', testEmail);
  console.log('Metadata:', signupData.user.user_metadata);

  // Try to insert profile with admin client
  const adminClient = createClient(supabaseUrl, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false }
  });

  console.log('\nAttempting to insert profile...');
  const { data: insertData, error: insertError } = await adminClient
    .from('profiles')
    .insert({
      id: userId,
      email: testEmail,
      username: signupData.user.user_metadata?.username || 'user',
      avatar_url: signupData.user.user_metadata?.avatar_url || null
    })
    .select();

  if (insertError) {
    console.log('❌ Insert error:');
    console.log('  Code:', insertError.code);
    console.log('  Message:', insertError.message);
    console.log('  Details:', insertError.details);
  } else {
    console.log('✓ Insert success:', insertData);
  }

  // Try to select it back
  console.log('\nAttempting to select profile...');
  const { data: selectData, error: selectError } = await adminClient
    .from('profiles')
    .select('*')
    .eq('id', userId)
    .single();

  if (selectError) {
    console.log('❌ Select error:');
    console.log('  Code:', selectError.code);
    console.log('  Message:', selectError.message);
  } else {
    console.log('✓ Select success:', selectData);
  }
}

testProfileInsert();
