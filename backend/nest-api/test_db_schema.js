const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://gauoglgismrwxtwsdaci.supabase.co';
const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdhdW9nbGdpc21yd3h0d3NkYWNpIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDQ1NjQ5OSwiZXhwIjoyMTAwMDMyNDk5fQ.KpW6jcb1y94jLXJkz0zklkLfS7VE35MCEjt1d_sEQ5Q';

async function checkSchema() {
  const adminClient = createClient(supabaseUrl, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false }
  });

  console.log('Checking Supabase schema...\n');

  // Try different tables
  const tables = ['users', 'profiles', 'auth.users', 'public.users'];
  
  for (const table of tables) {
    const { data, error } = await adminClient
      .from(table)
      .select('*', { count: 'exact', head: true });

    if (error) {
      console.log(`❌ ${table}: ${error.code} - ${error.message}`);
    } else {
      console.log(`✓ ${table} exists and is accessible`);
    }
  }

  console.log('\n📋 Checking entertainment table...');
  const { data: ent, error: entErr } = await adminClient
    .from('entertainment')
    .select('*', { count: 'exact', head: true });
  
  if (entErr) {
    console.log(`❌ entertainment: ${entErr.code} - ${entErr.message}`);
  } else {
    console.log('✓ entertainment table exists and is accessible');
  }
}

checkSchema();
