import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.7'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const serviceRoleKey = Deno.env.get('SERVICE_ROLE_KEY');

    if (!supabaseUrl || !serviceRoleKey) {
      throw new Error('Missing environment variables SUPABASE_URL or SERVICE_ROLE_KEY');
    }

    const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey);

    // Validate caller JWT
    const authHeader = req.headers.get('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return new Response(JSON.stringify({ error: 'Missing or invalid Authorization header' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const token = authHeader.split(' ')[1];
    
    // Get user info from token using admin client
    const { data: { user: caller }, error: callerError } = await supabaseAdmin.auth.getUser(token);
    if (callerError || !caller) {
      return new Response(JSON.stringify({ error: 'Unauthorized: Invalid token' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Check caller's role in profiles
    const { data: callerProfile, error: profileError } = await supabaseAdmin
      .from('profiles')
      .select('role')
      .eq('id', caller.id)
      .single();

    if (profileError || !callerProfile || callerProfile.role !== 'tu') {
      return new Response(JSON.stringify({ error: 'Forbidden: Only TU can perform this action' }), {
        status: 403,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Parse request body
    const body = await req.json();
    const { nama_lengkap, role, password } = body;
    let { email, nomor_hp } = body;

    // Validation
    if (!nama_lengkap || !role || !password) {
      return new Response(JSON.stringify({ error: 'Missing required fields: nama_lengkap, role, password' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    if (role === 'orang_tua') {
      if (!nomor_hp) {
        return new Response(JSON.stringify({ error: 'Missing nomor_hp for role orang_tua' }), {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
      }
      email = `${nomor_hp}@ortu.sitahfiz`;
    } else {
      if (!email) {
        return new Response(JSON.stringify({ error: 'Missing email for internal role' }), {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
      }
    }

    // Create user in auth.users
    const { data: authData, error: createUserError } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
    });

    if (createUserError) {
      return new Response(JSON.stringify({ error: createUserError.message }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const createdUser = authData.user;

    // Insert to corresponding tables
    if (role === 'orang_tua') {
      const { error: insertError } = await supabaseAdmin
        .from('orang_tua')
        .insert({
          id: createdUser.id,
          nama_lengkap,
          nomor_hp,
        });

      if (insertError) {
        // Rollback created auth user
        await supabaseAdmin.auth.admin.deleteUser(createdUser.id);
        return new Response(JSON.stringify({ error: insertError.message }), {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
      }
    } else {
      const { error: insertError } = await supabaseAdmin
        .from('profiles')
        .insert({
          id: createdUser.id,
          nama_lengkap,
          role,
          email,
        });

      if (insertError) {
        // Rollback created auth user
        await supabaseAdmin.auth.admin.deleteUser(createdUser.id);
        return new Response(JSON.stringify({ error: insertError.message }), {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
      }
    }

    // Insert to audit_trail
    const { error: auditError } = await supabaseAdmin
      .from('audit_trail')
      .insert({
        user_id: caller.id,
        aktivitas: `Buat akun: ${nama_lengkap}`,
      });

    if (auditError) {
      console.error('Audit trail logging failed:', auditError.message);
    }

    return new Response(JSON.stringify({ success: true, user_id: createdUser.id }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });

  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
})
