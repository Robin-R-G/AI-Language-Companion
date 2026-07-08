// supabase/functions/email-templates/index.ts
// Email template CRUD management

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { corsHeaders } from '../shared/cors.ts'
import { validateRequest } from '../shared/auth.ts'
import { successResponse, badRequest, unauthorized, notFound, serverError, createdResponse } from '../shared/errors.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { status: 200, headers: corsHeaders })
  }

  try {
    const auth = await validateRequest(req)
    if (auth.error) return auth.error

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Verify admin
    const { data: profile } = await supabaseAdmin
      .from('user_profiles')
      .select('role')
      .eq('auth_user_id', auth.user.id)
      .single()

    if (!profile || !['admin', 'super_admin'].includes(profile.role)) {
      return unauthorized('Admin access required')
    }

    const url = new URL(req.url)
    const pathParts = url.pathname.split('/').filter(Boolean)
    const templateId = pathParts.length > 1 ? pathParts[pathParts.length - 1] : null

    switch (req.method) {
      case 'GET': {
        if (templateId && templateId !== 'email-templates') {
          // Get single template
          const { data, error } = await supabaseAdmin
            .from('email_templates')
            .select('*')
            .eq('id', templateId)
            .single()

          if (error || !data) return notFound('Template not found')
          return successResponse(data)
        }

        // List all templates with optional filters
        const category = url.searchParams.get('category')
        const active = url.searchParams.get('active')
        const search = url.searchParams.get('search')

        let query = supabaseAdmin
          .from('email_templates')
          .select('*', { count: 'exact' })
          .order('category')
          .order('name')

        if (category) query = query.eq('category', category)
        if (active !== null) query = query.eq('is_active', active === 'true')
        if (search) query = query.or(`name.ilike.%${search}%,subject.ilike.%${search}%`)

        const { data, error, count } = await query
        if (error) return serverError(error.message)

        return successResponse(data, 'Templates retrieved', { total: count })
      }

      case 'POST': {
        const body = await req.json()
        const { name, slug, category, subject, html_body, text_body, variables, description } = body

        if (!name || !slug || !category || !subject || !html_body) {
          return badRequest('name, slug, category, subject, and html_body are required')
        }

        const validCategories = ['student', 'tutor', 'admin', 'system']
        if (!validCategories.includes(category)) {
          return badRequest(`category must be one of: ${validCategories.join(', ')}`)
        }

        // Check slug uniqueness
        const { data: existing } = await supabaseAdmin
          .from('email_templates')
          .select('id')
          .eq('slug', slug)
          .single()

        if (existing) {
          return badRequest('A template with this slug already exists')
        }

        const { data, error } = await supabaseAdmin
          .from('email_templates')
          .insert({
            name,
            slug,
            category,
            subject,
            html_body,
            text_body: text_body || null,
            variables: variables || [],
            description: description || null,
          })
          .select()
          .single()

        if (error) return serverError(error.message)
        return createdResponse(data, 'Template created successfully')
      }

      case 'PUT': {
        if (!templateId || templateId === 'email-templates') {
          return badRequest('Template ID required for update')
        }

        const body = await req.json()
        const { data, error } = await supabaseAdmin
          .from('email_templates')
          .update(body)
          .eq('id', templateId)
          .select()
          .single()

        if (error) return serverError(error.message)
        return successResponse(data, 'Template updated successfully')
      }

      case 'DELETE': {
        if (!templateId || templateId === 'email-templates') {
          return badRequest('Template ID required for deletion')
        }

        const { error } = await supabaseAdmin
          .from('email_templates')
          .delete()
          .eq('id', templateId)

        if (error) return serverError(error.message)
        return successResponse(null, 'Template deleted successfully')
      }

      default:
        return badRequest('Method not allowed')
    }
  } catch (error) {
    console.error('email-templates error:', error)
    return serverError(error instanceof Error ? error.message : 'Unknown error')
  }
})
