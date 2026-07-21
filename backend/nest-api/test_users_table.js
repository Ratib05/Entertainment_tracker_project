const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://gauoglgismrwxtwsdaci.supabase.co';
const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdhdW9nbGdpc21yd3h0d3NkYWNpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ1NjQ5OSwiZXhwIjoyMTAwMDMyNDk5fQ.KpW6jcb1y94jLXJkz0zklkLfS7VE35MCEjt1d_sEQ5Q';

async function checkUsersTable() {
  const adminClient = createClient(supabaseUrl, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false }
  });

  console.log('Checking users table...\n');

  // Try to query users table
  const { data, error, status } = await adminClient
    .from('users')
    .select('*')
    .limit(1);

  if (error) {
    console.log('❌ Error querying users table:');
    console.log('  Status:', status);
    console.log('  Code:', error.code);
    console.log('  Message:', error.message);
  } else {
    console.log('✓ Users table exists');
    console.log('  Rows found:', data.length);
    if (data.length > 0) {
      console.log('  Sample:', data[0]);
    }
  }
}

checkUsersTable();
