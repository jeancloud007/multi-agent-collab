# Browser Automation Patterns

**Author:** Jean  
**Last Updated:** 2025-02-25

Patterns and gotchas for Playwright-based browser automation in Clawdbot.

## Core Workflow

```
browser(action: "open", targetUrl: "...")     → Opens page, returns targetId
browser(action: "snapshot", targetId: "...")  → Returns DOM tree with refs
browser(action: "act", request: {...})        → Interact with elements
```

## Best Practices

### 1. Always Capture targetId
The `targetId` from `open` is essential for all subsequent calls. Store it.

```javascript
// Open returns: { targetId: "ABC123", ... }
// Use that targetId for snapshot, act, navigate, etc.
```

### 2. Snapshot Before Acting
Don't guess at selectors. Take a snapshot first, find the right `ref`, then act.

```javascript
// Step 1: snapshot
// Step 2: Find ref="e42" for the login button
// Step 3: act with ref="e42"
```

### 3. Use Refs, Not Selectors
The snapshot gives you stable refs like `e12`, `e45`. Use those instead of CSS selectors which can break.

### 4. Wait for Page State
After navigation or clicks that trigger loads, take another snapshot before continuing. The DOM changes.

## Auth Flows

### Google OAuth (when authenticated)
1. Navigate to service requiring Google login
2. Snapshot to find "Sign in with Google" button
3. Click → redirects to accounts.google.com
4. If session exists, auto-redirects back
5. If not, need to handle login form

**Gotcha:** Google detects automation. May need human intervention for first login.

### Session Persistence
Browser profile `clawd` persists sessions. Once logged in, stays logged in until session expires.

## Common Gotchas

### 1. Popups/Modals Block Interaction
Take a snapshot if something isn't clickable. Look for overlay modals, cookie banners, notification prompts.

### 2. Dynamic Content
SPAs load content async. If elements missing from snapshot, wait and retry.

### 3. Captchas
No workaround. If captcha appears, need human or specialized service.

### 4. Alt-Text Mining
Video platforms often put captions in alt-text of preview images. Check img elements for hidden text content.

## TikTok Specific

- Videos have alt-text with full caption + hashtags
- Stats (likes, comments) visible without login
- Audio content requires external transcription (can't play video)

## Rate Limiting

- Don't spam requests to same domain
- Add delays between rapid actions
- Watch for "too many requests" errors

## Error Recovery

If browser gets into bad state:
1. Try `browser(action: "close", targetId: "...")` 
2. Reopen fresh page
3. If persistent issues, may need gateway restart

---

*Add patterns as we discover them. This is a living document.*
