// supabase/functions/voice-service/index.ts
// Voice platform service: LiveKit token generation, STT, TTS, pronunciation analysis
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { validateAuth } from "../shared/auth.ts";
import { successResponse, badRequest, unauthorized, serverError } from "../shared/errors.ts";

const LIVEKIT_API_KEY = Deno.env.get("LIVEKIT_API_KEY") || "";
const LIVEKIT_API_SECRET = Deno.env.get("LIVEKIT_API_SECRET") || "";
const LIVEKIT_URL = Deno.env.get("LIVEKIT_URL") || "wss://your-livekit-server.com";

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204 });
  }

  try {
    const authResult = await validateAuth(req);
    if (authResult.error) {
      return unauthorized(authResult.error);
    }

    const userId = authResult.userId!;
    const url = new URL(req.url);
    const path = url.pathname.split("/").pop();

    switch (path) {
      case "token":
        return await handleTokenGeneration(req, userId);
      case "transcribe":
        return await handleTranscription(req, userId);
      case "pronunciation":
        return await handlePronunciationAnalysis(req, userId);
      case "tts":
        return await handleTextToSpeech(req, userId);
      default:
        return badRequest("Invalid endpoint");
    }
  } catch (error) {
    return serverError("Voice service error", error);
  }
});

async function handleTokenGeneration(req: Request, userId: string): Promise<Response> {
  const body = await req.json();
  const { sessionId, roomName, identity } = body;

  if (!sessionId || !roomName || !identity) {
    return badRequest("sessionId, roomName, and identity are required");
  }

  // Generate LiveKit token using HMAC
  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(LIVEKIT_API_SECRET),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: LIVEKIT_API_KEY,
    sub: identity,
    nbf: now,
    exp: now + 3600,
    video: {
      room: roomName,
      roomJoin: true,
      canPublish: true,
      canSubscribe: true,
      canPublishData: true,
    },
  };

  const header = btoa(JSON.stringify({ alg: "HS256", typ: "JWT" }))
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");

  const payloadStr = btoa(JSON.stringify(payload))
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");

  const signature = await crypto.subtle.sign(
    "HMAC",
    key,
    encoder.encode(`${header}.${payloadStr}`)
  );

  const signatureStr = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");

  const token = `${header}.${payloadStr}.${signatureStr}`;

  return successResponse({
    token,
    livekitUrl: LIVEKIT_URL,
    roomName,
    sessionId,
  });
}

async function handleTranscription(req: Request, userId: string): Promise<Response> {
  const formData = await req.formData();
  const audioFile = formData.get("audio") as File;
  const language = formData.get("language") as string || "en";

  if (!audioFile) {
    return badRequest("Audio file is required");
  }

  // Call Whisper API for transcription
  const whisperApiKey = Deno.env.get("WHISPER_API_KEY") || "";
  const whisperEndpoint = Deno.env.get("WHISPER_ENDPOINT") || "https://api.openai.com/v1/audio/transcriptions";

  const whisperFormData = new FormData();
  whisperFormData.append("file", audioFile);
  whisperFormData.append("model", "whisper-1");
  whisperFormData.append("language", language);
  whisperFormData.append("response_format", "verbose_json");
  whisperFormData.append("timestamp_granularities[]", "word");

  const whisperResponse = await fetch(whisperEndpoint, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${whisperApiKey}`,
    },
    body: whisperFormData,
  });

  if (!whisperResponse.ok) {
    return serverError("Transcription failed");
  }

  const transcriptionData = await whisperResponse.json();

  return successResponse({
    text: transcriptionData.text,
    confidence: transcriptionData.segments?.[0]?.avg_logprob ? Math.exp(transcriptionData.segments[0].avg_logprob) : 0.8,
    language: transcriptionData.language,
    words: transcriptionData.words?.map((w: any) => ({
      word: w.word,
      start: w.start,
      end: w.end,
      confidence: Math.exp(w.avg_logprob || 0),
    })) || [],
    duration: transcriptionData.duration,
  });
}

async function handlePronunciationAnalysis(req: Request, userId: string): Promise<Response> {
  const body = await req.json();
  const { transcript, target, language } = body;

  if (!transcript || !target) {
    return badRequest("transcript and target are required");
  }

  // Call AI for pronunciation analysis
  const aiProvider = Deno.env.get("AI_PROVIDER") || "openai";
  const apiKey = Deno.env.get(`${aiProvider.toUpperCase()}_API_KEY`) || "";
  const model = Deno.env.get(`${aiProvider.toUpperCase()}_MODEL`) || "gpt-4o";

  const analysisPrompt = `You are a pronunciation analysis expert for ${language} language learners.
Analyze the following spoken text against the target text and provide detailed pronunciation feedback.

Target text: "${target}"
Spoken text: "${transcript}"

Provide a JSON response with:
- overall_score (0-100)
- clarity (0-100)
- fluency (0-100)
- prosody (0-100)
- word_feedbacks: array of { word, score, issue, suggestion }
- suggestion: overall improvement tip

Only return valid JSON, no markdown.`;

  const aiResponse = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model,
      messages: [
        { role: "system", content: "You are a pronunciation analysis expert. Respond only in valid JSON." },
        { role: "user", content: analysisPrompt },
      ],
      temperature: 0.3,
      response_format: { type: "json_object" },
    }),
  });

  if (!aiResponse.ok) {
    return serverError("Pronunciation analysis failed");
  }

  const aiData = await aiResponse.json();
  const analysis = JSON.parse(aiData.choices[0].message.content);

  return successResponse({
    overall_score: analysis.overall_score || 0,
    clarity: analysis.clarity || 0,
    fluency: analysis.fluency || 0,
    prosody: analysis.prosody || 0,
    word_feedbacks: analysis.word_feedbacks || [],
    suggestion: analysis.suggestion || "",
  });
}

async function handleTextToSpeech(req: Request, userId: string): Promise<Response> {
  const body = await req.json();
  const { text, language, voiceId } = body;

  if (!text) {
    return badRequest("Text is required");
  }

  // Call TTS API (Cartesia, ElevenLabs, or OpenAI)
  const ttsProvider = Deno.env.get("TTS_PROVIDER") || "openai";
  const apiKey = Deno.env.get(`${ttsProvider.toUpperCase()}_API_KEY`) || "";

  if (ttsProvider === "openai") {
    const ttsResponse = await fetch("https://api.openai.com/v1/audio/speech", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "tts-1",
        input: text,
        voice: voiceId || "alloy",
        response_format: "opus",
        speed: 1.0,
      }),
    });

    if (!ttsResponse.ok) {
      return serverError("TTS generation failed");
    }

    const audioBuffer = await ttsResponse.arrayBuffer();
    return new Response(audioBuffer, {
      headers: {
        "Content-Type": "audio/opus",
        "Content-Length": audioBuffer.byteLength.toString(),
      },
    });
  }

  return badRequest(`TTS provider ${ttsProvider} not supported yet`);
}
