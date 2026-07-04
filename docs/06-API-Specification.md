# API Specification & Reference Document: AI Language Coach
**Version:** 1.0  
**Status:** Draft  
**Backend:** Supabase Edge Functions (deployed via Deno/TypeScript)  
**API Version:** v1  
**Last Updated:** July 2026  

---

## 1. Purpose
This document defines the API contract between the Flutter application and the backend services (Supabase Edge Functions), ensuring a consistent, secure, and versioned interface for all clients.

---

## 2. Base URL
*   **Production:** `https://api.yourdomain.com/v1` (Piped to production Edge Functions)
*   **Development:** `http://localhost:54321/functions/v1` (Local Supabase emulator)

*All requests in production require HTTPS.*

---

## 3. Authentication
Every protected request must include standard headers containing the user's JWT access token:

*   **Headers:**
    ```text
    Authorization: Bearer <JWT_ACCESS_TOKEN>
    Content-Type: application/json
    Accept: application/json
    ```

---

## 4. Standard Response Formats

### 4.1 Success Response Envelope (HTTP 200/201)
```json
{
  "success": true,
  "data": {},
  "message": "Operation completed successfully"
}
```

### 4.2 Error Response Envelope (HTTP 4xx/5xx)
```json
{
  "success": false,
  "error": {
    "code": "INVALID_REQUEST",
    "message": "Invalid request payload"
  }
}
```

---

## 5. Authentication APIs

### POST /auth/signup
*   **Description:** Create a new user credentials record.
*   **Auth Required:** No
*   **Request Body:**
    ```json
    {
      "email": "user@example.com",
      "password": "Password123",
      "name": "Rahul G"
    }
    ```
*   **Response (HTTP 201):**
    ```json
    {
      "success": true,
      "data": {
        "user_id": "c3b9b124-7622-48ea-8b4b-9d414e21f92e",
        "email": "user@example.com"
      },
      "message": "Verification link sent to email."
    }
    ```

### POST /auth/login
*   **Description:** Authenticate user credentials and return session tokens.
*   **Auth Required:** No
*   **Request Body:**
    ```json
    {
      "email": "user@example.com",
      "password": "Password123"
    }
    ```
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "access_token": "eyJhbGciOi...",
        "refresh_token": "d8f0b12...",
        "expires_in": 3600,
        "user_id": "c3b9b124-7622-48ea-8b4b-9d414e21f92e",
        "profile": {
          "name": "Rahul G",
          "native_language": "Malayalam",
          "target_language": "English",
          "subscription_tier": "Free"
        }
      },
      "message": "Login successful"
    }
    ```

### POST /auth/logout
*   **Description:** Invalidate active session tokens.
*   **Auth Required:** Yes
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": null,
      "message": "Logout successful"
    }
    ```

### POST /auth/refresh
*   **Description:** Rotate refresh token to obtain a fresh JWT access token.
*   **Auth Required:** No (Sends refresh token in request body)
*   **Request Body:**
    ```json
    {
      "refresh_token": "d8f0b12..."
    }
    ```
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "access_token": "eyJhbGciOi_new...",
        "refresh_token": "d8f0b12_new...",
        "expires_in": 3600
      },
      "message": "Token refreshed successfully"
    }
    ```

---

## 6. User Account APIs

### GET /users/me
*   **Description:** Fetch the active user's profile configuration and statistics.
*   **Auth Required:** Yes
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "user_id": "c3b9b124-7622-48ea-8b4b-9d414e21f92e",
        "name": "Rahul G",
        "email": "user@example.com",
        "native_language": "Malayalam",
        "target_language": "English",
        "current_level": "B1",
        "target_level": "C1",
        "daily_goal_minutes": 20,
        "subscription_tier": "Free",
        "streak_count": 5
      },
      "message": "User details retrieved"
    }
    ```

### PATCH /users/me
*   **Description:** Update fields in the user profile.
*   **Auth Required:** Yes
*   **Request Body:**
    ```json
    {
      "name": "Rahul G",
      "native_language": "Malayalam",
      "target_language": "English",
      "daily_goal_minutes": 30
    }
    ```
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "user_id": "c3b9b124-7622-48ea-8b4b-9d414e21f92e",
        "name": "Rahul G",
        "native_language": "Malayalam",
        "target_language": "English",
        "daily_goal_minutes": 30
      },
      "message": "User profile updated"
    }
    ```

### DELETE /users/me
*   **Description:** Wipes the user account and triggers GDPR cascading data deletes.
*   **Auth Required:** Yes
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": null,
      "message": "User account and all associated data deleted successfully."
    }
    ```

---

## 7. AI Chat & Lessons APIs

### POST /ai/chat
*   **Description:** Dispatch messages to AI tutors and return grammar corrections.
*   **Auth Required:** Yes
*   **Request Body:**
    ```json
    {
      "message": "Yesterday I go school.",
      "conversation_id": "e30cb41d-b8d9-482d-86cf-906a59b6623d",
      "mode": "conversation"
    }
    ```
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "reply": "I went to school yesterday too! What was your favorite class?",
        "grammar": [
          {
            "original": "Yesterday I go school.",
            "corrected": "Yesterday I went to school.",
            "explanation": "In English, actions completed in the past require the past simple verb form. 'Go' is irregular, and its past form is 'went'. Also, the verb 'went' requires the preposition 'to' before locations.",
            "explanation_malayalam": "കഴിഞ്ഞുപോയ കാര്യങ്ങൾ പറയാൻ 'went' എന്ന ഭൂതകാല രൂപമാണ് ഉപയോഗിക്കേണ്ടത്. കൂടാതെ സ്ഥലപ്പേരുകൾക്ക് മുൻപായി 'to' ചേർക്കേണ്ടതുണ്ട്."
          }
        ],
        "translation": "ഇന്നലെ ഞാൻ സ്കൂളിൽ പോയി.",
        "tokens_used": 240
      },
      "message": "Chat response processed"
    }
    ```

---

## 8. Grammar Checking APIs

### POST /grammar/check
*   **Description:** Evaluate text grammatical elements.
*   **Auth Required:** Yes
*   **Request Body:**
    ```json
    {
      "text": "She do not like apples."
    }
    ```
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "original": "She do not like apples.",
        "corrected": "She does not like apples.",
        "explanation": "For third-person singular pronouns (she, he, it), the verb 'does' is required instead of 'do'.",
        "rule": "Subject-Verb Agreement",
        "examples": [
          "He does not want to come.",
          "It does not matter."
        ]
      },
      "message": "Grammar evaluated"
    }
    ```

---

## 9. Translation APIs

### POST /translate
*   **Description:** Translate strings between target languages.
*   **Auth Required:** Yes
*   **Request Body:**
    ```json
    {
      "text": "Welcome to our class.",
      "target_language": "Malayalam"
    }
    ```
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "translation": "ഞങ്ങളുടെ ക്ലാസിലേക്ക് സ്വാഗതം.",
        "pronunciation": "Nhangalude class-ilekku swagatham",
        "examples": [
          {
            "original": "Welcome to our home.",
            "translated": "ഞങ്ങളുടെ വീട്ടിലേക്ക് സ്വാഗതം."
          }
        ]
      },
      "message": "Translation complete"
    }
    ```

---

## 10. Vocabulary APIs (SRS)

### GET /vocabulary/daily
*   **Description:** Retrieve daily vocabulary cards.
*   **Auth Required:** Yes
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "words": [
          {
            "id": "a90da23f-612a-43d9-a4c3-1d0b0aef8ccb",
            "word": "Diligent",
            "meaning": "Showing care and effort in work.",
            "meaning_malayalam": "കഠിനാധ്വാനമുള്ള",
            "pronunciation": "/ˈdɪl.ɪ.dʒənt/",
            "example_sentence": "He is a diligent student."
          }
        ]
      },
      "message": "Daily vocabulary queue loaded"
    }
    ```

### POST /vocabulary/save
*   **Description:** Save or update review parameters of a vocabulary card.
*   **Auth Required:** Yes
*   **Request Body:**
    ```json
    {
      "word_id": "a90da23f-612a-43d9-a4c3-1d0b0aef8ccb",
      "mastery_score": 4
    }
    ```
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "next_review": "2026-07-08T08:00:00Z"
      },
      "message": "Review interval updated"
    }
    ```

### GET /vocabulary/history
*   **Description:** Fetch the list of reviewed vocabulary.
*   **Auth Required:** Yes
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "words": [
          {
            "id": "a90da23f-612a-43d9-a4c3-1d0b0aef8ccb",
            "word": "Diligent",
            "mastery_level": "Good",
            "last_reviewed_at": "2026-07-04T08:00:00Z"
          }
        ]
      },
      "message": "Vocabulary history loaded"
    }
    ```

---

## 11. Lesson Plan APIs

### GET /lessons
*   **Description:** Fetch lesson arrays.
*   **Auth Required:** Yes
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "lessons": [
          {
            "id": "78dae39d-b8d9-482d",
            "title": "German Travel Conversations",
            "difficulty": "B2",
            "estimated_time_minutes": 15
          }
        ]
      },
      "message": "Lessons listed"
    }
    ```

### GET /lessons/:id
*   **Description:** Retrieve detailed lesson files and quiz units.
*   **Auth Required:** Yes
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "id": "78dae39d-b8d9-482d",
        "title": "German Travel Conversations",
        "content": "Lesson reading text...",
        "quizzes": [
          {
            "question_id": "q1",
            "question": "Where is the traveler heading?",
            "options": ["Munich", "Berlin"],
            "correct_option_index": 0
          }
        ]
      },
      "message": "Lesson details loaded"
    }
    ```

### POST /lessons/complete
*   **Description:** Flag a lesson unit as completed.
*   **Auth Required:** Yes
*   **Request Body:**
    ```json
    {
      "lesson_id": "78dae39d-b8d9-482d",
      "score": 100
    }
    ```
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "xp_earned": 50,
        "new_streak": 6
      },
      "message": "Lesson completion verified"
    }
    ```

### GET /lessons/recommended
*   **Description:** Fetch lessons suggestions matching target levels.
*   **Auth Required:** Yes
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "recommended_lessons": [
          {
            "id": "78dae39d-b8d9-482d",
            "title": "German Travel Conversations"
          }
        ]
      },
      "message": "Recommendations loaded"
    }
    ```

---

## 12. Voice Call APIs (LiveKit Server)

### POST /voice/session
*   **Description:** Initialize LiveKit room access.
*   **Auth Required:** Yes
*   **Request Body:**
    ```json
    {
      "language": "English",
      "persona": "David"
    }
    ```
*   **Response (HTTP 201):**
    ```json
    {
      "success": true,
      "data": {
        "session_id": "f8a02c89-612a-43d9-a4c3-1d0b0aef8a09",
        "token": "eyJhbGciOi...",
        "room_id": "room_f8a02c89"
      },
      "message": "Room session initialized"
    }
    ```

### POST /voice/end
*   **Description:** Conclude active LiveKit audio room sessions.
*   **Auth Required:** Yes
*   **Request Body:**
    ```json
    {
      "session_id": "f8a02c89-612a-43d9-a4c3-1d0b0aef8a09"
    }
    ```
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "duration_seconds": 320,
        "average_latency_ms": 480
      },
      "message": "Session ended. Transcript saved."
    }
    ```

---

## 13. Speaking & Writing Evaluation APIs

### POST /speaking/evaluate
*   **Description:** Analyze audio spoken performance.
*   **Auth Required:** Yes
*   **Headers:** `Content-Type: multipart/form-data`
*   **Request Body:** Binary audio payloads (WAV/M4A).
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "fluency": 85,
        "grammar": 80,
        "vocabulary": 82,
        "pronunciation": 78,
        "feedback": "Try relaxing between clauses to reduce short pauses.",
        "estimated_proficiency": "IELTS Band 7.0"
      },
      "message": "Evaluation processed"
    }
    ```

### POST /writing/evaluate
*   **Description:** Grade essay input text.
*   **Auth Required:** Yes
*   **Request Body:**
    ```json
    {
      "essay_text": "I think university education must be free because..."
    }
    ```
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "grammar": 80,
        "vocabulary": 75,
        "organization": 85,
        "clarity": 80,
        "estimated_proficiency": "IELTS Band 6.5",
        "suggestions": "Review subject-verb agreements in complex structures."
      },
      "message": "Writing evaluation processed"
    }
    ```

---

## 14. Mock Exam APIs

### GET /mock-exams
*   **Description:** Fetch lists of target exam packages.
*   **Auth Required:** Yes
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "exams": [
          {
            "id": "ex_123",
            "name": "IELTS Academic Test 1",
            "exam_type": "IELTS",
            "price": "Free"
          }
        ]
      },
      "message": "Exams listed"
    }
    ```

### POST /mock-exams/start
*   **Description:** Initialize timer variables.
*   **Auth Required:** Yes
*   **Request Body:**
    ```json
    {
      "exam_id": "ex_123"
    }
    ```
*   **Response (HTTP 201):**
    ```json
    {
      "success": true,
      "data": {
        "attempt_id": "att_123",
        "time_limit_minutes": 60
      },
      "message": "Exam started. Timer running."
    }
    ```

### POST /mock-exams/submit
*   **Description:** Submit exam responses.
*   **Auth Required:** Yes
*   **Request Body:**
    ```json
    {
      "attempt_id": "att_123",
      "answers": [
        { "question_id": "q1", "user_answer": "Option A" }
      ]
    }
    ```
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "score": 85,
        "passed": true,
        "detailed_report": "Feedback link..."
      },
      "message": "Exam submitted"
    }
    ```

### GET /mock-exams/history
*   **Description:** Load scores history logs.
*   **Auth Required:** Yes
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "attempts": [
          {
            "id": "att_123",
            "exam_name": "IELTS Academic Test 1",
            "score": 85,
            "created_at": "2026-07-04T08:00:00Z"
          }
        ]
      },
      "message": "History loaded"
    }
    ```

---

## 15. Dashboard & Analytics APIs

### GET /dashboard
*   **Description:** Retrieve dashboard statistics.
*   **Auth Required:** Yes
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "xp": 450,
        "level": 3,
        "streak": 5,
        "weekly_progress": [
          { "day": "Mon", "minutes": 15 },
          { "day": "Tue", "minutes": 20 }
        ],
        "skills": {
          "speaking": 82,
          "grammar": 75
        },
        "recommendations": ["Review past grammar cases Dative rule"]
      },
      "message": "Dashboard loaded"
    }
    ```

### GET /analytics/weekly
*   **Description:** Fetch weekly activity stats.
*   **Auth Required:** Yes
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "total_study_minutes": 120,
        "lessons_completed": 4
      },
      "message": "Weekly analytics loaded"
    }
    ```

---

## 16. Achievement APIs

### GET /achievements
*   **Description:** List unearned and earned badges.
*   **Auth Required:** Yes
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "achievements": [
          {
            "id": "ach_vocab_master",
            "title": "Vocabulary Master",
            "unlocked": true,
            "claimable": true
          }
        ]
      },
      "message": "Achievements listed"
    }
    ```

### POST /achievements/claim
*   **Description:** Claim badges.
*   **Auth Required:** Yes
*   **Request Body:**
    ```json
    {
      "achievement_id": "ach_vocab_master"
    }
    ```
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "xp_bonus": 100
      },
      "message": "Achievement badge claimed"
    }
    ```

---

## 17. Subscription APIs

### GET /subscription
*   **Description:** Load current subscription status.
*   **Auth Required:** Yes
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "tier": "Premium",
        "status": "Active",
        "expiry_date": "2026-08-04T08:00:00Z"
      },
      "message": "Subscription loaded"
    }
    ```

### POST /subscription/purchase
*   **Description:** Submit purchase tokens.
*   **Auth Required:** Yes
*   **Request Body:**
    ```json
    {
      "purchase_token": "tok_12345",
      "plan_type": "Premium"
    }
    ```
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "subscription_id": "sub_123"
      },
      "message": "Purchase verified. Premium activated."
    }
    ```

---

## 18. Notification APIs

### GET /notifications
*   **Description:** Retrieve notifications inbox.
*   **Auth Required:** Yes
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "notifications": [
          {
            "id": "not_1",
            "title": "Your streak is waiting!",
            "read": false
          }
        ]
      },
      "message": "Notifications loaded"
    }
    ```

### PATCH /notifications/read
*   **Description:** Mark notifications as read.
*   **Auth Required:** Yes
*   **Request Body:**
    ```json
    {
      "notification_ids": ["not_1"]
    }
    ```
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": null,
      "message": "Notifications read"
    }
    ```

### DELETE /notifications/:id
*   **Description:** Clear notifications.
*   **Auth Required:** Yes
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": null,
      "message": "Notification deleted"
    }
    ```

---

## 19. File Upload APIs (Sizes Limits)

### POST /upload/audio
*   **Description:** Upload audio recordings.
*   **Auth Required:** Yes
*   **Headers:** `Content-Type: multipart/form-data`
*   **Limits:** Maximum **25MB**.
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "file_url": "https://supabase.storage/audio/file_123.wav"
      },
      "message": "Audio uploaded successfully"
    }
    ```

### POST /upload/image
*   **Description:** Upload images.
*   **Auth Required:** Yes
*   **Headers:** `Content-Type: multipart/form-data`
*   **Limits:** Maximum **10MB**.
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "file_url": "https://supabase.storage/images/file_123.jpg"
      },
      "message": "Image uploaded successfully"
    }
    ```

---

## 20. AI Memory APIs

### GET /memory
*   **Description:** Fetch memory variables.
*   **Auth Required:** Yes
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "memories": ["Commonly misuses past tense 'went'"]
      },
      "message": "Memories loaded"
    }
    ```

### PATCH /memory
*   **Description:** Update memory flags.
*   **Auth Required:** Yes
*   **Request Body:**
    ```json
    {
      "memories": ["Commonly misuses past tense 'went'"]
    }
    ```
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": null,
      "message": "Memories updated"
    }
    ```

### DELETE /memory
*   **Description:** Clear memory parameters.
*   **Auth Required:** Yes
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": null,
      "message": "Memories cleared"
    }
    ```

---

## 21. Admin APIs (Restricted to Authorized Admins)

### GET /admin/users
*   **Description:** List users profiles.
*   **Auth Required:** Yes (Requires Admin claims)
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "users": [
          { "user_id": "c3b9b124", "email": "user@example.com" }
        ]
      },
      "message": "Users loaded"
    }
    ```

### GET /admin/feature-flags
*   **Description:** List active feature flags.
*   **Auth Required:** Yes (Requires Admin claims)
*   **Response (HTTP 200):**
    ```json
    {
      "success": true,
      "data": {
        "flags": {
          "enable_voice_beta": true
        }
      },
      "message": "Flags loaded"
    }
    ```

---

## 22. Standard Diagnostic Error Codes

```
+------------------+------------------------------+---------------------------+---------------------+
| ERROR CODE       | MESSAGE DESCRIPTION          | HTTP STATUS               | ACTION PROTOCOL     |
+------------------+------------------------------+---------------------------+---------------------+
| INVALID_REQUEST  | Malformed request payload    | 400 Bad Request           | Prompt user correction|
+------------------+------------------------------+---------------------------+---------------------+
| AUTH_001         | Unauthorized Token           | 401 Unauthorized          | Route to Login Screen|
+------------------+------------------------------+---------------------------+---------------------+
| FORBIDDEN_ACCESS | Action is forbidden          | 403 Forbidden             | Display gating banner|
+------------------+------------------------------+---------------------------+---------------------+
| NOT_FOUND        | Resource was not found       | 404 Not Found             | Return user to Home |
+------------------+------------------------------+---------------------------+---------------------+
| RATE_LIMIT_HIT   | Quota or request limits met   | 429 Rate Limited          | Show cooldown warning|
+------------------+------------------------------+---------------------------+---------------------+
| SERVER_ERR       | Internal backend errors      | 500 Internal Server Error | Log telemetry       |
+------------------+------------------------------+---------------------------+---------------------+
| AI_TIMEOUT       | AI Core Model Time Out       | 504 Gateway Timeout       | Redirect standard LLM|
+------------------+------------------------------+---------------------------+---------------------+
```

---

## 23. Rate Limiting Configurations
*   **Free Plan:** Limit clients to **50 API requests per day** and **5 voice minutes**.
*   **Premium Plan:** Limit clients to **1,000 API requests per day** and unlimited voice call minutes.

---

## 24. Webhooks Payload Events

### 24.1 subscription.created
```json
{
  "event_type": "subscription.created",
  "user_id": "c3b9b124-7622-48ea-8b4b-9d414e21f92e",
  "tier": "Premium"
}
```

### 24.2 lesson.completed
```json
{
  "event_type": "lesson.completed",
  "user_id": "c3b9b124-7622-48ea-8b4b-9d414e21f92e",
  "lesson_id": "78dae39d-b8d9-482d",
  "score": 100
}
```

### 24.3 user.deleted
```json
{
  "event_type": "user.deleted",
  "user_id": "c3b9b124-7622-48ea-8b4b-9d414e21f92e"
}
```

---

## 25. OpenAPI Integration & Spec Generation
*   The API specifications compile into `openapi.yaml` at the project root directory.
*   CI/CD pipelines automatically generate updated Swagger interfaces and Flutter client SDK classes upon `openapi.yaml` updates.

---

## 26. API Testing Checklist

Every API endpoint must:
*   [ ] Verify successful outcomes (HTTP 200/201).
*   [ ] Validate parameter formats and return HTTP 400 or HTTP 422 upon error.
*   [ ] Reject requests lacking valid JWT access tokens (HTTP 401).
*   [ ] Enforce RLS rules to isolate user data.
*   [ ] Return standard error response envelopes.
