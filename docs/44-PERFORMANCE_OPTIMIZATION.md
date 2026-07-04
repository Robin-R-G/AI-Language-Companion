# Performance Optimization & Latency SLA Guide (44-PERFORMANCE_OPTIMIZATION)
**Version:** 1.0  
**Status:** Production  
**Target Environment:** Frontend Rendering Engines, Dio Clients, LiveKit Connections, Postgres Pools  
**Last Updated:** July 2026  

---

## 1. Purpose
This document defines the performance targets, optimization strategies, resource usage rules, and scalability requirements for **AI Language Coach**. 

Following this guide ensures a fast startup, fluid UI animations, low-latency audio connection, and efficient battery consumption.

---

## 2. Performance SLA Targets

The application must meet the following performance targets:
*   **App Startup Time:** Cold start under **3 seconds**, warm start under **1 second**.
*   **Screen Transitions:** Render navigation pushes in under **200ms**.
*   **Frame Rate:** 60 FPS minimum (120 FPS on supported high-refresh screens).
*   **Memory Footprint:** Keep runtime heap allocation under **250MB**.
*   **Battery Consumption:** Average study session consumes less than **5% battery charge per hour**.
*   **AI API Response Latency:** Text generation responses complete in under **2 seconds** (excluding long streaming).
*   **Voice Stream Latency:** Round-trip audio connection latency (LiveKit WebRTC) under **300ms**.
*   **Crash-Free Sessions:** Maintain a crash-free session rate above **99.5%**.

---

## 3. Frontend Rendering & State Optimizations

### 3.1 Flutter Rendering Guidelines
*   **Const Constructors:** Declare widgets with `const` constructors to bypass redundant element rebuilds.
*   **Widget Splitting:** Keep widget structures small. Split complex widgets into dedicated subclasses.
*   **Lazy Lists Building:** Use `ListView.builder` for scroll feeds to dynamically allocate elements.
*   **Minimize Rebuilds:** Isolate local rebuild areas using Riverpod `Consumer` selectors.

### 3.2 State Management Rules (Riverpod)
*   **AutoDispose:** Use autoDispose to release memory when screens go out of focus.
*   **AsyncNotifier:** Manage asynchronous mutations using `AsyncNotifier` structures.
*   **Selector Watch:** Use `ref.watch(provider.select(...))` to filter state update triggers.

### 3.3 Visual & Asset Compression
*   **Images:** Compress files in WebP format. Use vector SVGs for UI icons.
*   **Caching:** Store network images locally using caches (`CachedNetworkImage`).

---

## 4. Network & Database Performance

### 4.1 API & Dio Configuration
*   **Compression:** Enable GZIP compression on HTTP requests.
*   **Batching & Pagination:** Batch analytics updates. Paginate list endpoints.
*   **Retry Transient Errors:** Retry socket timeouts (Attempt 1 to Attempt 3) using exponential backoff, but reject automatic retries on client-side errors.

### 4.2 Supabase Database Optimization
*   **RLS Indexes:** Create corresponding indexes on database foreign keys and columns queried by Row-Level Security policies.
*   **Query Constraints:** Avoid fetching unnecessary columns (e.g. avoid `select *`). Enforce query row count limits.
*   **Connection Pooling:** Configure connection pooling for database read and write channels.

---

## 5. Voice, AI & Offline Operations

### 5.1 Real-Time Spoken Audio (LiveKit)
*   **Bitrate Limits:** Optimize audio codecs (e.g. Opus encoding) to minimize bandwidth.
*   **Voice Activity Detection (VAD):** Adjust VAD sensitivity thresholds to prevent background noise from triggering streams.
*   **Latency Goal:** Keep connection latency under the **300ms** target.

### 5.2 LLM Token Optimizations
*   **Prompt Sizes:** Prune context arrays. Summarize long conversations to keep tokens below prompt size thresholds.
*   **Cost-Efficient Providers:** Route standard tutoring requests to fast flash models (Gemini Flash) and utilize large models (GPT-4o) only for exams evaluations.

### 5.3 Offline Caching Strategies
*   **Caching Scope:** Cache static lessons, vocabulary cards database, user goals, and translation history locally in Isar/Hive databases.
*   **State Exclusions:** Never cache authentication credentials, session tokens, or private billing details.
*   **Background sync:** Keep background synchronization tasks minimal and use event-driven triggers rather than interval polling.

---

## 6. Memory, Storage & Load Testing

*   **Disposal:** Dispose of text fields controllers, animation drivers, file logs, and sound controllers inside `dispose()` methods to prevent memory leaks.
*   **Storage Cleanup:** Delete temporary files, diagnostic crash logs, and expired lesson download archives automatically.
*   **Load Testing Scopes:** Run weekly load tests simulating:
    1.  Concurrent users surges.
    2.  Edge Functions request bursts.
    3.  LiveKit voice channel connections timeouts.

---

## 7. Performance QA Gate Checklist

Verify the performance setup against this checklist before production release:
*   [ ] Does the app launch under the 3-second cold start target?
*   [ ] Do scrollable widgets scroll smoothly at 60+ FPS?
*   [ ] Are list queries paginated and bounded?
*   [ ] Are database indexes active on RLS foreign key columns?
*   [ ] Has LiveKit audio latency been verified under 300ms?
*   [ ] Do controllers and stream listeners dispose of their states securely?
*   [ ] Are assets compressed to WebP and SVG formats?
*   [ ] Has load testing verified server response bounds during concurrency peaks?
