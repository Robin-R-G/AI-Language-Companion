// supabase/functions/files/index.ts
// Section 24: File APIs
// POST /files/upload, GET /files/{id}, DELETE /files/{id}
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { validateRequest } from '../shared/auth.ts'
import {
  successResponse,
  noContentResponse,
  badRequest,
  validationError,
  notFound,
  serverError,
} from '../shared/errors.ts'
import { corsHeaders } from '../shared/cors.ts'

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const authResult = await validateRequest(req)
  if (authResult.error) return authResult.error
  if (authResult.isPreflight) return authResult.response!

  try {
    const supabase = authResult.supabaseClient
    const userId = authResult.user.id
    const url = new URL(req.url)
    const pathParts = url.pathname.split('/').filter(Boolean)
    const action = pathParts[pathParts.length - 1]

    // POST /files/upload - Upload file
    if (req.method === 'POST' && action === 'upload') {
      const contentType = req.headers.get('content-type') || ''

      if (!contentType.includes('multipart/form-data')) {
        return badRequest('Content-Type must be multipart/form-data')
      }

      const formData = await req.formData()
      const file = formData.get('file') as File | null
      const folder = (formData.get('folder') as string) || 'uploads'

      if (!file) {
        return badRequest('No file provided')
      }

      // Validate file size (max 50MB)
      if (file.size > 50 * 1024 * 1024) {
        return validationError('File too large', ['Maximum size is 50MB'])
      }

      // Validate file type
      const allowedTypes = [
        'image/jpeg', 'image/png', 'image/webp', 'image/gif',
        'audio/mpeg', 'audio/wav', 'audio/ogg',
        'video/mp4', 'video/webm',
        'application/pdf',
        'text/plain',
      ]

      if (!allowedTypes.includes(file.type)) {
        return validationError('File type not allowed', [
          'Allowed: Images (JPEG, PNG, WebP, GIF), Audio (MP3, WAV, OGG), Video (MP4, WebM), PDF, Text',
        ])
      }

      const fileExt = file.name.split('.').pop() || 'bin'
      const filePath = `${folder}/${userId}/${Date.now()}-${Math.random().toString(36).substring(7)}.${fileExt}`

      const arrayBuffer = await file.arrayBuffer()
      const { data, error: uploadError } = await supabase.storage
        .from('files')
        .upload(filePath, arrayBuffer, {
          contentType: file.type,
          upsert: false,
        })

      if (uploadError) {
        console.error('File upload error:', uploadError)
        return serverError('Failed to upload file')
      }

      // Get public URL
      const { data: urlData } = supabase.storage
        .from('files')
        .getPublicUrl(filePath)

      return successResponse({
        id: filePath,
        name: file.name,
        size: file.size,
        type: file.type,
        url: urlData.publicUrl,
        folder,
        created_at: new Date().toISOString(),
      }, 'File uploaded successfully.')
    }

    // GET /files/{id} - Download/get file
    if (req.method === 'GET' && action !== 'upload') {
      const filePath = action

      if (!filePath) {
        return badRequest('File path required')
      }

      // Check if file exists
      const { data: fileData, error: downloadError } = await supabase.storage
        .from('files')
        .download(filePath)

      if (downloadError) {
        return notFound('File not found')
      }

      // Get file metadata
      const { data: metadata } = await supabase.storage
        .from('files')
        .getPublicUrl(filePath)

      return new Response(fileData, {
        status: 200,
        headers: {
          ...corsHeaders,
          'Content-Type': fileData.type || 'application/octet-stream',
          'Content-Disposition': `attachment; filename="${filePath.split('/').pop()}"`,
        },
      })
    }

    // DELETE /files/{id} - Delete file
    if (req.method === 'DELETE' && action !== 'upload') {
      const filePath = action

      if (!filePath) {
        return badRequest('File path required')
      }

      // Verify user owns the file
      if (!filePath.includes(userId)) {
        return badRequest('Access denied')
      }

      const { error: deleteError } = await supabase.storage
        .from('files')
        .remove([filePath])

      if (deleteError) {
        console.error('File delete error:', deleteError)
        return serverError('Failed to delete file')
      }

      return noContentResponse()
    }

    return badRequest('Method not allowed')
  } catch (error) {
    console.error('Files error:', error)
    return serverError(error.message || 'Internal server error')
  }
})
