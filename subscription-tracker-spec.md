# Subscription Tracker — Product & Technical Specification

**Version:** 1.0 · **Date:** 2026-07-08 · **Platform:** Flutter (iOS + Android) · **Backend:** PHP API + PostgreSQL

---

## 1. Overview

A mobile app to track recurring subscriptions (streaming, SaaS, gym, utilities, etc.), inspired by Bobby. Users see what they pay, when renewals happen, and get reminded before charges. The app is **local-first**: fully functional offline with no account; an optional account (Google/Apple Sign-In) enables cross-device sync and shared groups.

### Core principles

- **Local-first:** SQLite is the source of truth on device. Every feature in Phase 1 works with no network and no account.
- **Sync is additive:** the sync layer replicates local data; it never becomes a requirement for core usage.
- **Sharing via groups:** subscriptions are organized in groups/subgroups; groups can be shared with other registered users.

### Delivery phases

| Phase | Scope | Account required |
|---|---|---|
| **1 — MVP (local-only)** | Subscription CRUD, groups/subgroups, reminders, dashboard, local backup/export | No |
| **2 — Accounts & Sync** | Google/Apple Sign-In, multi-device sync via PHP API | Optional |
| **3 — Shared Groups** | Invite users to groups, roles, shared editing, activity feed | Yes (for sharing) |
| **4 — Premium & Growth** | Freemium gating, insights, multi-currency rates, widgets, extras | — |

---

## 2. Phase 1 — MVP (Local-first, no account)

### 2.1 Subscriptions

Fields:

- **name** (required), **service** (optional link to a bundled service catalog with logo/color; free-text fallback with auto-generated icon)
- **price** (decimal) + **currency** (default from device locale)
- **billing cycle:** weekly, monthly, quarterly, semi-annual, yearly, or custom (every N days/weeks/months)
- **first bill date** → app computes **next renewal date** automatically (rolls forward on each renewal)
- **free trial support:** trial end date; app converts to paid on that date and warns before it
- **status:** active, paused, canceled (canceled keeps history but leaves totals)
- **payment method** (free-text label, e.g., "Nubank credit card"), **notes**, **URL** (to manage/cancel the service)
- **group/subgroup** assignment (optional; ungrouped allowed)

Actions: create, edit, duplicate, pause/resume, cancel, delete (with undo snackbar). Price changes are stored as **price history** entries (date + old/new price).

### 2.2 Groups & subgroups

- Tree structure, **max depth 2** (group → subgroup) to keep UI simple. E.g., *Entertainment → Streaming*.
- Group fields: name, icon, color.
- A subscription belongs to at most one group/subgroup.
- Group view shows aggregated monthly/yearly cost including subgroups.
- Deleting a group offers: move contents up / ungroup / delete subscriptions.
- Seed defaults on first launch: Entertainment (Streaming, Music, Games), Work, Health, Utilities — user can edit/remove.

### 2.3 Reminders (local notifications)

- Per-subscription reminders: N days before renewal (defaults: 3 days and same-day; configurable globally and per subscription).
- Trial-ending reminders (default: 3 days before trial end).
- Implemented with `flutter_local_notifications` scheduled locally; rescheduled on every renewal roll-forward and on app launch.

### 2.4 Dashboard & views

- **Home:** total spend per month (normalized: yearly/12 etc.), upcoming renewals list (next 30 days), spend by group (donut/bar).
- **Calendar view:** month grid with renewal markers.
- **List view:** all subscriptions, sortable (next renewal, price, name), filterable by group/status; search.
- Amount displayed as monthly-equivalent and yearly-equivalent toggles.

### 2.5 Local backup / export

- Export/import full data as a versioned JSON file (share sheet / file picker).
- CSV export of subscriptions for spreadsheets.

### 2.6 Settings

- Default currency, default reminder rules, theme (light/dark/system), language (EN + PT-BR at launch), first day of week.

### 2.7 Out of scope for Phase 1

No account, no network calls (except optional service-logo catalog bundled in the app), no sharing, no IAP.

---

## 3. Architecture (client)

```
┌─ Presentation (Flutter widgets) ─────────────┐
│  Riverpod providers / controllers            │
├─ Domain ─────────────────────────────────────┤
│  Entities, use-cases, repository interfaces  │
├─ Data ───────────────────────────────────────┤
│  Drift (SQLite) DAOs  │  Sync engine (P2)    │
│  Local notifications  │  API client (dio)    │
└──────────────────────────────────────────────┘
```

### Recommended stack

| Concern | Package |
|---|---|
| Local DB | `drift` (SQLite, typed, reactive queries) |
| State management | `riverpod` (or `flutter_bloc` if the team prefers) |
| Navigation | `go_router` |
| Models/serialization | `freezed` + `json_serializable` |
| Notifications | `flutter_local_notifications` + `timezone` |
| Auth (P2) | `google_sign_in`, `sign_in_with_apple` |
| HTTP (P2) | `dio` |
| Charts | `fl_chart` |
| IAP (P4) | `purchases_flutter` (RevenueCat) |
| Money | store amounts as integer minor units (cents) |

### Data model (client, Drift tables)

All rows carry sync metadata from day one so Phase 2 requires no migration:

```
common columns: id TEXT (UUIDv7, generated on device), created_at, updated_at (UTC ms),
                deleted_at NULL (soft delete / tombstone), dirty BOOL (pending push)

subscriptions(id, name, service_slug?, price_minor INT, currency CHAR(3),
              cycle_unit ENUM(day,week,month,year), cycle_count INT,
              first_bill_date DATE, next_bill_date DATE,
              trial_end_date DATE?, status ENUM(active,paused,canceled),
              payment_method TEXT?, notes TEXT?, manage_url TEXT?,
              group_id FK?, owner_scope TEXT)  -- 'personal' or group scope, see §5.4

groups(id, name, icon, color, parent_id FK?)   -- parent_id NULL = top-level; depth ≤ 2 enforced in app + API

price_history(id, subscription_id FK, changed_at, old_price_minor, new_price_minor)

reminder_rules(id, subscription_id FK?, days_before INT)  -- NULL subscription_id = global default

settings(key, value)  -- local only, not synced
```

`next_bill_date` is derived but persisted (needed for notification scheduling and cheap queries); a roll-forward job runs on app open and via background fetch.

---

## 4. Phase 2 — Accounts & Sync

### 4.1 Authentication

- **Sign in with Google** and **Sign in with Apple** only (no email/password). Apple Sign-In is mandatory on iOS when social login exists.
- Client obtains the provider **ID token** and posts it to the API; the API verifies the token signature/audience against Google/Apple JWKS, then creates/finds the user and issues:
  - short-lived **access JWT** (15 min) + rotating **refresh token** (stored in secure storage, `flutter_secure_storage`).
- On first sign-in, local data is adopted by the account and pushed (see migration below). On sign-out, local data stays on device (user choice: keep or wipe).

### 4.2 Backend stack

- **PHP 8.3+** — recommended framework: **Laravel 11** (auth middleware, queues, Eloquent, scheduler) or **Slim 4** if you want it minimal. Spec assumes Laravel.
- **PostgreSQL 16**. UUID primary keys, `BIGSERIAL server_seq` for sync cursors.
- JSON REST API, versioned under `/v1`. OpenAPI spec maintained in repo.

### 4.3 Server schema (core)

```
users(id UUID PK, provider ENUM(google,apple), provider_uid TEXT, email, name,
      avatar_url, plan ENUM(free,premium), created_at)
      UNIQUE(provider, provider_uid)

devices(id UUID PK, user_id FK, platform, name, last_sync_at)
refresh_tokens(id, user_id, device_id, token_hash, expires_at, revoked_at)

groups(id UUID PK, owner_user_id FK, name, icon, color, parent_id FK?,
       is_shared BOOL, created_at, updated_at, deleted_at, server_seq BIGSERIAL)

group_members(group_id FK, user_id FK, role ENUM(owner,editor,viewer),
              joined_at, PK(group_id, user_id))

subscriptions(same fields as client + owner_user_id FK?, group_id FK?,
              updated_at, deleted_at, server_seq BIGSERIAL)
      -- owner_user_id set when personal; group_id set when it lives in a shared group

price_history(... , server_seq)
invites(id, group_id FK, inviter_id FK, code TEXT UNIQUE, email?, role,
        expires_at, accepted_by?, accepted_at)
```

Trigger: any INSERT/UPDATE bumps `server_seq` from a global sequence — this gives a total order for pull cursors.

### 4.4 Sync protocol (delta sync + LWW)

Design: **operation-free row sync** (simpler than CRDTs, adequate for this data shape).

- Every syncable row: `id` (client-generated UUIDv7), `updated_at` (client clock, UTC), `deleted_at` (tombstone), server-side `server_seq`.
- **Push** — `POST /v1/sync/push` with batch of dirty rows `{table, rows[]}`. Server upserts using **last-write-wins on `updated_at`** (tie-break: higher device id). Response returns accepted/rejected per row + authoritative versions.
- **Pull** — `GET /v1/sync/pull?cursor=<server_seq>&scope=<scope_id>` returns all rows with `server_seq > cursor` for scopes the user can access, plus `next_cursor`. Client upserts locally with the same LWW rule.
- **Scopes:** `user:{id}` (personal data) and `group:{id}` for each shared group. Client stores one cursor per scope.
- Sync runs: on app foreground, after local mutations (debounced 5 s), on push notification "sync hint" (P3), and pull-to-refresh.
- **Tombstones** retained 90 days server-side, then purged; clients syncing after that do a full re-pull.
- **Conflicts:** row-level LWW is acceptable (fields are small and edits rare). Price edits also append `price_history`, so no data is silently lost. Clock skew mitigated by capping client `updated_at` at server time + 5 min.
### 4.5 Login merge (LATR-style, user-driven)

On sign-in, before continuous sync is enabled, run an explicit merge flow modeled on LATR's `login_merge.dart` / `SyncService`:

1. **Snapshot:** `beginLoginMerge()` pulls a full server snapshot (`cursor = null`, personal scope only — shared-group data is always server-authoritative and excluded from this flow) and computes:
   - `localHasData` / `serverHasData` (live rows only, tombstones and seed/example data ignored)
   - `conflicts`: rows with the **same id** on both sides, different `updated_at`, and at least one content field differing.
2. **Only one side (or neither) has data → auto-merge**, no UI: apply server snapshot additively (`skipTombstones` — old server deletions never wipe local rows) and/or push everything (push watermark = 0 when only local has data). Save pull cursor from snapshot `server_time`.
3. **Both sides have data → mode picker** (bottom sheet, "Your account has N subscriptions and this device also has data — how do you want to combine?"):
   - **Merge everything** *(recommended, non-destructive)* — union of both sides; real conflicts resolved **item by item** in a resolver sheet (radio per item: "This device" / "Account", with "apply to all" shortcuts; default = keep local).
   - **Use account data only** *(destructive)* — confirmation dialog → wipe local user data → apply full snapshot → push watermark = now (nothing to push).
   - **Use this device's data only** *(destructive)* — confirmation dialog → `POST /v1/sync/wipe` on server → push watermark = 0 (re-push everything).
4. **Safe-by-default rules** (copy LATR exactly): dismissing the picker or any interruption (navigation away, declined confirmation) falls back to **merge**, never a destructive mode and never leaving sync half-configured; conflicts resolved as "keep local" get their `updated_at` touched to *now* so they win LWW on the next push; "server wins" conflict choices are force-applied bypassing LWW.
5. After any path: save pull cursor + push watermark, then `enableContinuous()`.

Requires one extra endpoint: `POST /v1/sync/wipe` (deletes the user's personal-scope data server-side; never touches shared groups).

### 4.6 API endpoints (Phase 2)

```
POST /v1/auth/google           {id_token}            → {access, refresh, user}
POST /v1/auth/apple            {identity_token, ...} → {access, refresh, user}
POST /v1/auth/refresh          {refresh}             → {access, refresh}
POST /v1/auth/logout
GET  /v1/me                                          → profile, plan, limits
DELETE /v1/me                  (account deletion — App Store requirement)
GET  /v1/sync/pull?cursor&scope
POST /v1/sync/push
POST /v1/sync/wipe            (login merge: "device wins" — clears personal scope)
GET  /v1/catalog/services      (service names/logos/colors, cached, versioned)
```

---

## 5. Phase 3 — Shared Groups

### 5.1 Model

- Any top-level group can be **shared**; its subgroups and subscriptions are shared with it.
- Both parties must have accounts. Personal (non-shared) data is never visible to others.
- **Roles:** `owner` (manage members, delete group), `editor` (CRUD subscriptions/subgroups), `viewer` (read-only).

### 5.2 Invites

- Owner creates an invite → server generates a short **invite code / deep link** (`app://invite/XYZ`), optionally bound to an email. Expires in 7 days.
- Invitee opens link (or enters code) while signed in → `POST /v1/invites/accept` → membership created → group scope appears in their next pull.

### 5.3 Membership endpoints (server-authoritative, not via sync push)

```
POST   /v1/groups/{id}/share            (mark shared)
POST   /v1/groups/{id}/invites          {role, email?}   → {code, link}
POST   /v1/invites/accept               {code}
GET    /v1/groups/{id}/members
PATCH  /v1/groups/{id}/members/{uid}    {role}
DELETE /v1/groups/{id}/members/{uid}    (kick / leave)
```

### 5.4 Sync interaction

- When a group becomes shared, its rows move from scope `user:{owner}` to scope `group:{id}` (server rewrites scope; clients pick it up on next pull).
- Permission checks on push: editors/owner may write; viewer writes rejected with `403` per-row (client reverts local change and informs user).
- **Push notifications (FCM + APNs):** sent to members on changes in shared groups ("Ana added Disney+ to Streaming — R$ 33.90/mo") and as silent "sync hint" pushes.
- **Activity feed** per shared group: server-logged events (added/edited/canceled/member joined), `GET /v1/groups/{id}/activity`.

### 5.5 Cost splitting (proposal, see §7)

Optional per-subscription split among members (equal or custom shares); each member's dashboard shows *their* share in totals.

---

## 6. Phase 4 — Freemium & Monetization

**Free:**

- Unlimited local subscriptions and groups
- Reminders, dashboard, calendar, export/backup
- Sync limited to **1 device** (account allowed)

**Premium (monthly/yearly IAP, via RevenueCat):**

- Multi-device sync
- Shared groups (create/join unlimited; free users can *join* 1 shared group)
- Advanced insights (§7), multi-currency conversion, price-change alerts
- Home-screen widgets, custom icons/themes, unlimited price history

Entitlement stored in `users.plan`, validated server-side via RevenueCat webhooks; client checks a local cached entitlement for UI gating. Limits enforced in API (e.g., device count, group creation) — never trust the client.

---

## 7. Proposed extra features (for your review)

Each item is independent — tell me which you like:

1. **Smart insights:** "You spend R$ 187/mo on streaming — 22% more than 6 months ago"; unused-subscription nudges ("Mark as still using?" quarterly check-in).
2. **Price-increase watch:** since price history exists, alert when a subscription's cost rises and show lifetime increase per service.
3. **Cancellation helper:** per-service "how to cancel" deep link/instructions in the catalog + a "cancel before renewal" checklist flow.
4. **Multi-currency with live rates:** daily FX rates cached by the API; totals converted to home currency.
5. **Annual-vs-monthly optimizer:** flags subscriptions where switching to yearly billing would save money (catalog knows both prices).
6. **Home-screen widgets:** next renewals + monthly total (iOS WidgetKit / Android Glance).
7. **Calendar integration:** optional export of renewals to device calendar (read-only ICS or native calendar API).
8. **Cost-splitting in shared groups:** define shares per member; dashboards show individual burden (great for couples/roommates).
9. **Spending timeline & reports:** monthly historical chart, year-in-review summary ("You spent R$ 3,240 on subscriptions in 2026").
10. **Email/SMS parsing is intentionally excluded** (privacy/complexity) — but a **quick-add via catalog search** with prefilled prices keeps entry fast.

---

## 8. Non-functional requirements

- **Privacy:** local mode sends zero data. Synced data encrypted in transit (TLS); no third-party analytics on financial data (use privacy-friendly analytics like self-hosted Plausible-style events, opt-in).
- **Security:** JWT auth, refresh rotation with reuse detection, rate limiting, provider token verification against JWKS, per-row ACL on sync scopes. LGPD/GDPR: data export + account deletion endpoints.
- **Offline:** every screen renders from Drift; sync failures never block UI; dirty rows retried with exponential backoff.
- **Performance:** dashboard queries < 16 ms at 1,000 subscriptions; sync batches capped at 500 rows.
- **i18n:** EN + PT-BR via `intl`/ARB; currency/date formatting per locale.
- **Accessibility:** dynamic type, semantic labels, WCAG AA contrast.
- **Testing:** unit tests for renewal/cycle math and sync merge logic (critical!), widget tests for main flows, API integration tests for sync + permissions; contract tests against the OpenAPI spec.

---

## 9. Milestones (suggested)

| # | Milestone | Contents |
|---|---|---|
| M1 | App skeleton | Drift schema, navigation, theming, settings |
| M2 | Subscriptions core | CRUD, cycles, renewal math + unit tests |
| M3 | Groups + dashboard | Tree UI, aggregation, calendar/list views |
| M4 | Reminders + backup | Notifications, JSON/CSV export — **MVP ship** |
| M5 | API + auth | Laravel setup, Google/Apple auth, `/me` |
| M6 | Sync engine | Push/pull, LWW, login-merge flow (mode picker + conflict resolver, §4.5) |
| M7 | Shared groups | Invites, roles, scopes, push notifications, activity feed |
| M8 | Premium | RevenueCat, gating, paywall, widgets/insights |

---

## 10. Open decisions

1. App name & branding.
2. Laravel vs Slim for the PHP API (spec assumes Laravel).
3. Free-tier limits final numbers (§6 values are proposals).
4. Which §7 extras enter the roadmap and in which phase.
