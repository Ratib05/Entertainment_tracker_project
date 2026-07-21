const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://gauoglgismrwxtwsdaci.supabase.co';
const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdhdW9nbGdpc21yd3h0d3NkYWNpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ1NjQ5OSwiZXhwIjoyMTAwMDMyNDk5fQ.KpW6jcb1y94jLXJkz0zklkLfS7VE35MCEjt1d_sEQ5Q';

async function listTables() {
  const adminClient = createClient(supabaseUrl, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false }
  });

  console.log('Checking Supabase tables...\n');

  // Try different approaches to list tables
  const tableNames = [
    'users', 'profiles', 'entertainment', 'library', 'reviews', 'lists', 'statistics'
  ];

  for (const table of tableNames) {
    const { data, error, status } = await adminClient
      .from(table)
      .select('*', { count: 'exact', head: true });

    if (error && error.code === 'PGRST116') {
      console.log(`✓ ${table} - exists (empty or no rows)`);
    } else if (error && error.code === 'PGRST205') {
      console.log(`❌ ${table} - DOES NOT EXIST`);
    } else if (error) {
      console.log(`⚠️  ${table} - Error: ${error.code}`);
    } else {
      console.log(`✓ ${table} - exists (${data?.length || 0} rows)`);
    }
  }

  console.log('\n💡 Status: Database tables need to be created in Supabase');
}

listTables();
