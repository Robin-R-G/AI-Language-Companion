// supabase/functions/files-api/index.ts
// Files API Edge Function - Upload, Download, Delete
import { validateRequest } from '../shared/auth.ts'
import {
  successResponse,
  badRequest,
  notFound,
  serverError,
  noContentResponse,
} from '../shared/errors.ts'
import { corsHeaders } from '../shared/cors.ts'

const BUCKET_NAME = 'user-files'
const MAX_FILE_SIZE = 10 * 1024 * 1024 // 10MB

function extractFileId(pathname: string): string | null {
  const prefix = '/files-api/files/'
  if (pathname.startsWith(prefix)) {
    return pathname.slice(prefix.length) || null
  }
  return null
}

async function handleUpload(
  supabase: any,
  userId: string,
  req: Request,
): Promise<Response> {
  const contentType = req.headers.get('content-type') || ''

  if (!contentType.includes('multipart/form-data')) {
    return badRequest('Content-Type must be multipart/form-data')
  }

  const formData = await req.formData()
  const file = formData.get('file') as File | null

  if (!file) {
    return badRequest('No file provided. Include a "file" field in the form data.')
  }

  if (file.size > MAX_FILE_SIZE) {
    return badRequest(`File size exceeds the ${MAX_FILE_SIZE / (1024 * 1024)}MB limit`)
  }

  const fileExtension = file.name.split('.').pop() || ''
  const timestamp = Date.now()
  const filePath = `${userId}/${timestamp}-${crypto.randomUUID()}.${fileExtension}`

  const arrayBuffer = await file.arrayBuffer()
  const fileBuffer = new Uint8Array(arrayBuffer)

  const { data, error } = await supabase.storage
    .from(BUCKET_NAME)
    .upload(filePath, fileBuffer, {
      contentType: file.type,
      upsert: false,
    })

  if (error) {
    console.error('Storage upload error:', error)
    return serverError('Failed to upload file to storage')
  }

  return successResponse(
    {
      id: filePath,
      name: file.name,
      size: file.size,
      type: file.type,
      path: data.path,
    },
    'File uploaded successfully.',
  )
}

async function handleDownload(
  supabase: any,
  userId: string,
  fileId: string,
): Promise<Response> {
  const { data, error } = await supabase.storage
    .from(BUCKET_NAME)
    .download(fileId)

  if (error) {
    console.error('Storage download error:', error)
    return notFound('File not found or access denied')
  }

  const headers = new Headers(corsHeaders)
  headers.set('Content-Type', data.type || 'application/octet-stream')
  headers.set('Content-Disposition', `attachment; filename="${fileId.split('/').pop()}"`)

  return new Response(data, {
    status: 200,
    headers,
  })
}

async function handleDelete(
  supabase: any,
  userId: string,
  fileId: string,
): Promise<Response> {
  const { error } = await supabase.storage
    .from(BUCKET_NAME)
    .remove([fileId])

  if (error) {
    console.error('Storage delete error:', error)
    return serverError('Failed to delete file')
  }

  return noContentResponse()
}

Deno.serve(async (req: Request) => {
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
    const path = url.pathname

    // POST /files-api/files/upload
    if (req.method === 'POST' && path === `${BASE_PATH}/files/upload`) {
      return await handleUpload(supabase, userId, req)
    }

    // DELETE /files-api/files/{id}
    if (req.method === 'DELETE' && path.startsWith(`${BASE_PATH}/files/`)) {
      const fileId = extractFileId(path)
      if (!fileId) {
        return badRequest('Invalid file ID')
      }
      return await handleDelete(supabase, userId, fileId)
    }

    // GET /files-api/files/{id}
    if (req.method === 'GET' && path.startsWith(`${BASE_PATH}/files/`)) {
      const fileId = extractFileId(path)
      if (!fileId) {
        return badRequest('Invalid file ID')
      }
      return await handleDownload(supabase, userId, fileId)
    }

    return badRequest('Route not found')
  } catch (error) {
    console.error('Files API error:', error)
    return serverError(error.message || 'Internal server error')
  }
})

const BASE_PATH = '/files-api'
