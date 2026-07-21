const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://gauoglgismrwxtwsdaci.supabase.co';
const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdhdW9nbGdpc21yd3h0d3NkYWNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ0NTY0OTksImV4cCI6MjEwMDAzMjQ5OX0.0NwaVZPSIEeuJ3_O7pxnex2H2yFL45IYzP9SP7ni-rI';
const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdhdW9nbGdpc21yd3h0d3NkYWNpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ1NjQ5OSwiZXhwIjoyMTAwMDMyNDk5fQ.KpW6jcb1y94jLXJkz0zklkLfS7VE35MCEjt1d_sEQ5Q';

async function testProfileLoad() {
  console.log('Testing profile load...\n');

  // Create a test user
  const anonClient = createClient(supabaseUrl, anonKey);
  const { data: signupData } = await anonClient.auth.signUp({
    email: `test_${Date.now()}@example.com`,
    password: 'TestPass123!'
  });

  const userId = signupData.user.id;
  console.log('Created user:', userId);

  // Try to load profile with admin client
  const adminClient = createClient(supabaseUrl, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false }
  });

  console.log('\n1️⃣ Trying public.users table:');
  const { data: publicUsersData, error: publicUsersError } = await adminClient
    .from('public.users')
    .select('id, email, username, avatar_url')
    .eq('id', userId)
    .single();

  if (publicUsersError) {
    console.log('  ❌ Error:', publicUsersError.code, '-', publicUsersError.message);
  } else {
    console.log('  ✓ Success:', publicUsersData);
  }

  console.log('\n2️⃣ Trying profiles table:');
  const { data: profilesData, error: profilesError } = await adminClient
    .from('profiles')
    .select('id, email, username, avatar_url')
    .eq('id', userId)
    .single();

  if (profilesError) {
    console.log('  ❌ Error:', profilesError.code, '-', profilesError.message);
  } else {
    console.log('  ✓ Success:', profilesData);
  }

  console.log('\n3️⃣ Checking what tables exist:');
  const { data: tables, error: tablesError } = await adminClient
    .from('information_schema.tables')
    .select('table_name')
    .eq('table_schema', 'public')
    .order('table_name');

  if (tablesError) {
    console.log('  ❌ Error:', tablesError.code, '-', tablesError.message);
  } else {
    console.log('  ✓ Public tables:');
    tables?.forEach(t => console.log('    -', t.table_name));
  }
}

testProfileLoad();
