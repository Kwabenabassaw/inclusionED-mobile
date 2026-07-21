<instruction>You are an expert software engineer. You are working on a WIP branch. Please run `git status` and `git diff` to understand the changes and the current state of the code. Analyze the workspace context and complete the mission brief.</instruction>
<workspace_context>
<artifacts>
--- CURRENT TASK CHECKLIST ---
- [x] Phase 1 — API Service Layer (`lib/supportApi.js`)
  - [x] Implement `supportTicketsApi`
  - [x] Implement `supportKnowledgeApi`
  - [x] Implement `supportSlaApi`
  - [x] Implement `supportAnalyticsApi`
  - [x] Implement `portalSupportApi`
- [x] Phase 2 — React Query Hooks (`hooks/useSupportData.js`)
  - [x] Create ticket hooks (`useTickets`, `useTicket`, etc.)
  - [x] Create knowledge hooks
  - [x] Create SLA hooks
  - [x] Create analytics hooks
- [x] Phase 3 — Zustand Support Store (`store/supportStore.js`)
  - [x] Implement UI state store
- [x] Phase 4 — Internal Agent Workspace (Main Module)
  - [x] `SupportDashboard.jsx` (List & Kanban views)
  - [x] `TicketDetail.jsx` (Thread, Meta Panel, Timeline)
  - [x] `KnowledgeBase.jsx` & `KnowledgeArticleEditor.jsx`
  - [x] `SupportAnalytics.jsx`
  - [x] `SlaManagement.jsx`
- [x] Phase 5 — Customer Portal Support
  - [x] `ClientSupport.jsx` (Ticket list & detail view)
  - [x] CSAT Survey UI
- [x] Phase 6 — Updates to existing files
  - [x] Update `sidebar.workspace.config.ts`
  - [x] Update `router/index.jsx`
  - [x] Update permissions constants
- [x] Phase 7 — Real-time Updates (SignalR)
  - [x] Integrate SignalR for ticket updates

--- IMPLEMENTATION PLAN ---
# Support Module — Frontend Implementation Plan

## Background

The backend Support Module is built and the API is available at:
- Internal (Agent) API: `/api/support/...`
- Portal (Customer) API: `/api/portal/support/...`

Both `pages/crm/Tickets.jsx` and `pages/workspace/Support.jsx` are currently `<ComingSoon />` stubs.
`pages/ClientPortal/ClientSupport.jsx` is also a stub.

The existing `ticketsApi` in `lib/api.js` is a **mock localStorage implementation** that must be replaced with real HTTP calls to the new backend endpoints.

---

## Tech Stack (Match the Existing Codebase Exactly)

| Layer | Technology |
|---|---|
| Framework | React 19 + Vite |
| Routing | React Router v7 |
| State (server) | TanStack React Query v5 |
| State (global UI) | Zustand v5 |
| UI Components | shadcn/ui + Radix UI |
| Forms | react-hook-form + zod |
| Charts | Recharts |
| Styling | Tailwind CSS v3 |
| Icons | Lucide React |
| HTTP Client | Axios (via `apiClient` from `lib/api.js`) |
| Animations | Framer Motion |

> [!IMPORTANT]
> Never use plain `fetch()`. Always go through `apiClient` from `lib/api.js`.
> All API services follow the same `createResourceService` / `createPutResourceService` factory pattern.
> Pages use `PageContainer` + `PageHeader` layout wrappers (see Projects.jsx, Leads.jsx).
> Import `showToast` from `components/ui/Toast` for all user feedback.

---

## What to Build

The Support Module frontend has **two surfaces**:
1. **Internal Agent/Admin Workspace** — the full-power, multi-panel interface for agents, supervisors, and managers.
2. **Customer Portal** — a stripped-down, customer-facing ticket interface integrated into the existing `ClientPortal` section.

Plus a **sidebar expansion** and an **admin configuration** section for SLA, teams, and escalation rules.

---

## Proposed Changes

### Phase 1 — API Service Layer

#### [MODIFY] [api.js](file:///c:/Users/Kobby/Desktop/Project_techtopia/techtopiagh_crm_web/Techtopia_advanced/src/lib/api.js)

Replace the mock `ticketsApi` at line 268 with real HTTP calls:

```js
// Replace:
export const ticketsApi = createMockResourceService('crm_tickets', MOCK_TICKETS);

// With a full Support API layer:
export const supportTicketsApi = {
  list: (params) => apiClient.get('/api/support/tickets', { params }).then(r => r.data),
  get: (id) => apiClient.get(`/api/support/tickets/${id}`).then(r => r.data),
  create: (data) => apiClient.post('/api/support/tickets', data).then(r => r.data),
  update: (id, data) => apiClient.put(`/api/support/tickets/${id}`, data).then(r => r.data),
  delete: (id) => apiClient.delete(`/api/support/tickets/${id}`).then(r => r.data),
  restore: (id) => apiClient.post(`/api/support/tickets/${id}/restore`).then(r => r.data),
  updateStatus: (id, data) => apiClient.patch(`/api/support/tickets/${id}/status`, data).then(r => r.data),
  assign: (id, data) => apiClient.post(`/api/support/tickets/${id}/assign`, data).then(r => r.data),
  merge: (id, data) => apiClient.post(`/api/support/tickets/${id}/merge`, data).then(r => r.data),
  getTimeline: (id) => apiClient.get(`/api/support/tickets/${id}/timeline`).then(r => r.data),
  pauseSla: (id) => apiClient.post(`/api/support/tickets/${id}/sla/pause`).then(r => r.data),
  resumeSla: (id) => apiClient.post(`/api/support/tickets/${id}/sla/resume`).then(r => r.data),
  bulkAssign: (data) => apiClient.post('/api/support/tickets/bulk-assign', data).then(r => r.data),
  bulkClose: (data) => apiClient.post('/api/support/tickets/bulk-close', data).then(r => r.data),
  bulkDelete: (data) => apiClient.post('/api/support/tickets/bulk-delete', data).then(r => r.data),
  export: (params) => apiClient.get('/api/support/tickets/export', { params, responseType: 'blob' }).then(r => r.data),
  getComments: (id) => apiClient.get(`/api/support/tickets/${id}/comments`).then(r => r.data),
  addComment: (id, data) => apiClient.post(`/api/support/tickets/${id}/comments`, data).then(r => r.data),
  editComment: (ticketId, commentId, data) => apiClient.put(`/api/support/tickets/${ticketId}/comments/${commentId}`, data).then(r => r.data),
  deleteComment: (ticketId, commentId) => apiClient.delete(`/api/support/tickets/${ticketId}/comments/${commentId}`).then(r => r.data),
  addAttachment: (id, formData) => apiClient.post(`/api/support/tickets/${id}/attachments`, formData, { headers: { 'Content-Type': 'multipart/form-data' } }).then(r => r.data),
  deleteAttachment: (ticketId, attachmentId) => apiClient.delete(`/api/support/tickets/${ticketId}/attachments/${attachmentId}`).then(r => r.data),
  addWatcher: (id, data) => apiClient.post(`/api/support/tickets/${id}/watchers`, data).then(r => r.data),
  removeWatcher: (id, userId) => apiClient.delete(`/api/support/tickets/${id}/watchers/${userId}`).then(r => r.data),
};

export const supportKnowledgeApi = {
  listArticles: (params) => apiClient.get('/api/support/knowledge/articles', { params }).then(r => r.data),
  getArticle: (id) => apiClient.get(`/api/support/knowledge/articles/${id}`).then(r => r.data),
  createArticle: (data) => apiClient.post('/api/support/knowledge/articles', data).then(r => r.data),
  updateArticle: (id, data) => apiClient.put(`/api/support/knowledge/articles/${id}`, data).then(r => r.data),
  publishArticle: (id) => apiClient.post(`/api/support/knowledge/articles/${id}/publish`).then(r => r.data),
  archiveArticle: (id) => apiClient.post(`/api/support/knowledge/articles/${id}/archive`).then(r => r.data),
  deleteArticle: (id) => apiClient.delete(`/api/support/knowledge/articles/${id}`).then(r => r.data),
  listCategories: () => apiClient.get('/api/support/knowledge/categories').then(r => r.data),
};

export const supportSlaApi = {
  listPolicies: () => apiClient.get('/api/support/sla/policies').then(r => r.data),
  getPolicy: (id) => apiClient.get(`/api/support/sla/policies/${id}`).then(r => r.data),
  createPolicy: (data) => apiClient.post('/api/support/sla/policies', data).then(r => r.data),
  updatePolicy: (id, data) => apiClient.put(`/api/support/sla/policies/${id}`, data).then(r => r.data),
  deletePolicy: (id) => apiClient.delete(`/api/support/sla/policies/${id}`).then(r => r.data),
};

export const supportAnalyticsApi = {
  getTicketVolume: (params) => apiClient.get('/api/support/analytics/volume', { params }).then(r => r.data),
  getAgentPerformance: (params) => apiClient.get('/api/support/analytics/agents', { params }).then(r => r.data),
  getSlaCompliance: (params) => apiClient.get('/api/support/analytics/sla', { params }).then(r => r.data),
};

// Portal API (Customer-facing)
export const portalSupportApi = {
  listTickets: () => apiClient.get('/api/portal/support/tickets').then(r => r.data),
  getTicket: (id) => apiClient.get(`/api/portal/support/tickets/${id}`).then(r => r.data),
  createTicket: (data) => apiClient.post('/api/portal/support/tickets', data).then(r => r.data),
  addComment: (id, data) => apiClient.post(`/api/portal/support/tickets/${id}/comments`, data).then(r => r.data),
};
```

---

#### [NEW] [lib/supportApi.js](file:///c:/Users/Kobby/Desktop/Project_techtopia/techtopiagh_crm_web/Techtopia_advanced/src/lib/supportApi.js)

Dedicated module that re-exports all support-related API services (keeps api.js clean for non-support modules).

---

### Phase 2 — React Query Hooks

#### [NEW] [hooks/useSupportData.js](file:///c:/Users/Kobby/Desktop/Project_techtopia/techtopiagh_crm_web/Techtopia_advanced/src/hooks/useSupportData.js)

Following the exact same pattern as `useCrmData.js`. Hook functions to expose:

```js
// Ticket hooks
export function useTickets(filters) { ... }
export function useTicket(id) { ... }
export function useTicketTimeline(id) { ... }
export function useTicketComments(ticketId) { ... }

// Knowledge hooks
export function useKnowledgeArticles(filters) { ... }
export function useKnowledgeArticle(id) { ... }
export function useKnowledgeCategories() { ... }

// SLA hooks
export function useSlaPolicies() { ... }

// Analytics hooks
export function useSupportAnalytics(params) { ... }

// Support agents & teams (reusing existing usersApi for agent list)
export function useSupportAgents() { ... }
```

Each hook includes:
- `useQuery` for reads
- `useMutation` with `queryClient.invalidateQueries` for writes
- `auditTrack.*` calls following existing patterns
- `showToast` success/error messaging

---

### Phase 3 — Zustand Support Store

#### [NEW] [store/supportStore.js](file:///c:/Users/Kobby/Desktop/Project_techtopia/techtopiagh_crm_web/Techtopia_advanced/src/store/supportStore.js)

Manages purely UI state that doesn't need to hit the server:
- `selectedTicketId` — currently open ticket in the detail panel
- `viewMode` — `'list' | 'kanban'` for the main ticket list
- `activeFilters` — `{ status[], priority[], assignee, category }`
- `searchQuery` — global search term
- `isSideDrawerOpen` — controls the detail drawer

---

### Phase 4 — Internal Agent Workspace (Main Module)

#### [MODIFY] [pages/workspace/Support.jsx](file:///c:/Users/Kobby/Desktop/Project_techtopia/techtopiagh_crm_web/Techtopia_advanced/src/pages/workspace/Support.jsx)

Replace `<ComingSoon />` stub. This becomes the **main agent workspace** — the hub page.

Layout: **two-panel sidebar-content design**:
- Left panel (collapsible): Saved views / filter presets, team queue counts
- Main panel: ticket list (table or kanban), configurable via view toggle

Key features:
- **Saved Views** in the left rail (My Open Tickets, All Unassigned, SLA At Risk, etc.)
- **Priority filter tabs** (All / Critical / High / Medium / Low)
- **Status filter chips** (New / Assigned / In Progress / Pending / Resolved / Closed)
- **Full-text search** (debounced, 300ms)
- **Sortable, paginated table** using `@tanstack/react-table`
- **SLA countdown indicator** per row — color coded (green / amber / red)
- **Bulk select + bulk actions bar** (Assign / Close / Delete)
- **Quick Status dropdown** inline in the table row
- **View toggle** — List / Kanban
- **"New Ticket" button** → opens `CreateTicketDrawer`

#### [NEW] [pages/Support/](file:///c:/Users/Kobby/Desktop/Project_techtopia/techtopiagh_crm_web/Techtopia_advanced/src/pages/Support/)

The full Support section under its own directory:

```
src/pages/Support/
  SupportDashboard.jsx         ← hub page (replaces workspace/Support.jsx)
  TicketDetail.jsx             ← full ticket detail page at /support/tickets/:id
  KnowledgeBase.jsx            ← knowledge article list + editor
  KnowledgeArticleEditor.jsx   ← rich text article creation/editing
  SlaManagement.jsx            ← SLA policy configuration (admin)
  SupportAnalytics.jsx         ← KPI dashboard with Recharts
  SupportTeamsAdmin.jsx        ← team + agent management (admin)
```

#### [NEW] [pages/Support/SupportDashboard.jsx](file:///c:/Users/Kobby/Desktop/Project_techtopia/techtopiagh_crm_web/Techtopia_advanced/src/pages/Support/SupportDashboard.jsx)

The main workspace. UI breakdown:

**Header Row:**
```
[📋 SLA Tickets]  [🔍 Search...]  [Filters ▾]  [View: List|Kanban]  [+ New Ticket]
```

**KPI Strip (4 cards):**
| Open | Unassigned | SLA At Risk | CSAT Score |
| --- | --- | --- | --- |
| 142 | 17 | 8 | 4.7 ★ |

**Left Sidebar Drawer (collapsible):**
- My Tickets (12)
- Team Queue (45)
- Unassigned (17)
- SLA Breached (3)
- *Saved Views* section (user custom)

**Main Table columns:**
- ☐ Checkbox
- #Ticket Number (with link)
- Subject (truncated + tooltip)
- Contact / Company
- Priority badge (colored)
- Status badge
- Assigned Agent avatar
- SLA Countdown (`HH:MM` green/amber/red)
- Created date
- Actions (…)

**Bulk Action Bar** (appears when rows checked):
- Assign To ▾ | Mark Closed | Delete | Export

#### [NEW] [pages/Support/TicketDetail.jsx](file:///c:/Users/Kobby/Desktop/Project_techtopia/techtopiagh_crm_web/Techtopia_advanced/src/pages/Support/TicketDetail.jsx)

Route: `/support/tickets/:id`

Three-column layout:
- **Left rail** (200px): Metadata panel (status, priority, type, source, SLA bar, watchers)
- **Center** (flex): Thread / conversation view. Public replies + internal notes tab-separated. Rich-text composer.
- **Right rail** (280px): Contact info, Linked company, Tags, Attachments, Similar articles from KB

Key features:
- Status state machine buttons — only valid transitions shown (cannot move to an illegal state)
- **"Assign to me"** and **"Assign to agent"** quick action
- Comment type toggle: Public Reply / Internal Note (different background colors)
- **@mention** support in comment composer
- **Attachment uploads** (drag & drop, 50MB max)
- **Ticket Timeline** collapsible at the bottom
- **SLA Pause / Resume** button for admin/supervisor roles
- **AI Suggested Reply** button (calls `IAiReplyGenerator` via backend)

#### [NEW] [pages/Support/KnowledgeBase.jsx](file:///c:/Users/Kobby/Desktop/Project_techtopia/techtopiagh_crm_web/Techtopia_advanced/src/pages/Support/KnowledgeBase.jsx)

Route: `/support/knowledge`

Split view:
- Left: Category tree + search
- Right: Article cards grouped by category

Status badges: Draft / Under Review / Published / Archived

Actions: View, Edit, Publish, Archive, Delete

#### [NEW] [pages/Support/KnowledgeArticleEditor.jsx](file:///c:/Users/Kobby/Desktop/Project_techtopia/techtopiagh_crm_web/Techtopia_advanced/src/pages/Support/KnowledgeArticleEditor.jsx)

Route: `/support/knowledge/new` and `/support/knowledge/:id/edit`

A simple markdown or rich-text editor using a `<textarea>` (can be upgraded to a WYSIWYG editor later). Fields: Title, Category, Tags, Content, Status action buttons (Save Draft / Submit for Review / Publish).

#### [NEW] [pages/Support/SupportAnalytics.jsx](file:///c:/Users/Kobby/Desktop/Project_techtopia/techtopiagh_crm_web/Techtopia_advanced/src/pages/Support/SupportAnalytics.jsx)

Route: `/support/analytics`

Recharts dashboard:
- Ticket volume over time (AreaChart)
- Tickets by status (PieChart)
- SLA compliance rate (RadialBarChart)
- Agent performance table (tickets resolved, CSAT, avg resolution time)
- Date range picker (last 7 / 30 / 90 days / custom)

#### [NEW] [pages/Support/SlaManagement.jsx](file:///c:/Users/Kobby/Desktop/Project_techtopia/techtopiagh_crm_web/Techtopia_advanced/src/pages/Support/SlaManagement.jsx)

Route: `/support/admin/sla`

Admin-only page:
- SLA Policy list (name, response time, resolution time, priority scope, default?)
- Create / Edit policy modal (shadcn Dialog)
- Business hours configuration (day-of-week toggles + time pickers)
- Holiday calendar (add / remove dates)

---

### Phase 5 — Customer Portal Support

#### [MODIFY] [pages/ClientPortal/ClientSupport.jsx](file:///c:/Users/Kobby/Desktop/Project_techtopia/techtopiagh_crm_web/Techtopia_advanced/src/pages/ClientPortal/ClientSupport.jsx)

Replace `<ComingSoon />` stub. Simple two-panel portal view:

**Left panel:** My Tickets list with status badge
**Right panel (or drawer):** Selected ticket view
- Thread / conversation (public replies only)
- Reply composer
- Attachment list

**Header CTA:** "Submit New Ticket" → modal form

---

### Phase 6 — CRM/Tickets stub page

#### [MODIFY] [pages/crm/Tickets.jsx](file:///c:/Users/Kobby/Desktop/Project_techtopia/techtopiagh_crm_web/Techtopia_advanced/src/pages/crm/Tickets.jsx)

Redirect to `/support` or render a summary/quick-view of the agent workspace (reuse `SupportDashboard` component).

---

### Phase 7 — Sidebar Navigation Update

#### [MODIFY] [components/layout/config/sidebar.workspace.config.ts](file:///c:/Users/Kobby/Desktop/Project_techtopia/techtopiagh_crm_web/Techtopia_advanced/src/components/layout/config/sidebar.workspace.config.ts)

Expand the `support` group items to expose the full module:

```ts
// Support Group — Replace the two existing stub items with:
{ id: 'support-dashboard', label: 'Ticket Workspace', url: '/support', group: 'support', permission: PERMISSIONS.VIEW_SUPPORT },
{ id: 'support-knowledge', label: 'Knowledge Base', url: '/support/knowledge', group: 'support', permission: PERMISSIONS.VIEW_SUPPORT },
{ id: 'support-analytics', label: 'Support Analytics', url: '/support/analytics', group: 'support', permission: PERMISSIONS.VIEW_ANALYTICS },
{ id: 'support-sla', label: 'SLA Policies', url: '/support/admin/sla', group: 'support', permission: PERMISSIONS.ADMIN_SUPPORT },
```

A new permission constant `PERMISSIONS.ADMIN_SUPPORT` must be added to `constants/permissions.js`.

---

### Phase 8 — Router Update

#### [MODIFY] [router/index.jsx](file:///c:/Users/Kobby/Desktop/Project_techtopia/techtopiagh_crm_web/Techtopia_advanced/src/router/index.jsx)

Add lazy imports and routes for all new pages:

```jsx
// New lazy imports
const SupportDashboard = lazy(() => import('../pages/Support/SupportDashboard'));
const TicketDetail = lazy(() => import('../pages/Support/TicketDetail'));
const KnowledgeBase = lazy(() => import('../pages/Support/KnowledgeBase'));
const KnowledgeArticleEditor = lazy(() => import('../pages/Support/KnowledgeArticleEditor'));
const SupportAnalytics = lazy(() => import('../pages/Support/SupportAnalytics'));
const SlaManagement = lazy(() => import('../pages/Support/SlaManagement'));

// New routes (inside ProtectedRoute wrapper)
<Route path="/support" element={<SupportDashboard />} />
<Route path="/support/tickets/:id" element={<TicketDetail />} />
<Route path="/support/knowledge" element={<KnowledgeBase />} />
<Route path="/support/knowledge/new" element={<KnowledgeArticleEditor />} />
<Route path="/support/knowledge/:id/edit" element={<KnowledgeArticleEditor />} />
<Route path="/support/analytics" element={<SupportAnalytics />} />
<Route path="/support/admin/sla" element={<SlaManagement />} />
```

---

## Reusable Sub-Components to Build

All go into `src/pages/Support/components/`:

| Component | Purpose |
|---|---|
| `TicketCard.jsx` | Kanban card for board view |
| `TicketRow.jsx` | Row for table view (with bulk checkbox) |
| `SlaCountdown.jsx` | Live countdown badge (updates every minute) |
| `TicketStatusBadge.jsx` | Status → styled badge mapping |
| `PriorityBadge.jsx` | Priority → styled badge with icon |
| `CreateTicketModal.jsx` | New ticket creation dialog (reusable from multiple contexts) |
| `TicketCommentThread.jsx` | Chat-style message list |
| `CommentComposer.jsx` | Tab-based (Public Reply / Internal Note) rich text box |
| `TicketMetaPanel.jsx` | Right/left rail metadata panel |
| `TicketTimelinePanel.jsx` | Immutable event log |
| `BulkActionBar.jsx` | Floating bar that appears on multi-select |
| `SavedViewsList.jsx` | Left rail with saved filters |

---

## Design Guidelines

Follow the existing Techtopia dark-mode aesthetic from `index.css`:
- Use `bg-card`, `border-border`, `text-foreground` tokens
- SLA badges: `text-green-400` → On Track / `text-yellow-400` → At Risk / `text-red-500` → Breached
- Priority: Critical = red pulse dot / High = orange / Medium = blue / Low = gray
- Internal notes: `bg-yellow-950/20 border-yellow-800/40` (distinct from public replies)
- Use `framer-motion` for panel transitions and drawer open/close
- SLA countdown uses `date-fns formatDuration` and re-renders every 60 seconds via `setInterval`

---

## Implementation Order

1. `lib/supportApi.js` + update `lib/api.js`
2. `hooks/useSupportData.js`
3. `store/supportStore.js`
4. `pages/Support/SupportDashboard.jsx` + sub-components (TicketRow, TicketCard, SlaCountdown, BulkActionBar)
5. `pages/Support/TicketDetail.jsx` + sub-components (CommentThread, Composer, MetaPanel)
6. `pages/Support/KnowledgeBase.jsx` + Editor
7. `pages/Support/SupportAnalytics.jsx`
8. `pages/Support/SlaManagement.jsx` (admin)
9. `pages/ClientPortal/ClientSupport.jsx`
10. Sidebar config update + router update + permissions constant

---

## Open Questions

> [!IMPORTANT]
> 1. **Kanban view**: Do you want a kanban board (columns by status) in addition to the table view on the Dashboard?
> 2. **AI Suggested Reply button**: Should this call the backend AI endpoint now (stub will return null), or should it be wired up visually but disabled until an AI provider is configured?
> 3. **Real-time updates**: Should new tickets or comment notifications trigger real-time updates using the existing SignalR hub (`/hubs/audit`) or use polling via React Query's `refetchInterval`?
> 4. **Ticket pagination**: Infinite scroll (react-query `useInfiniteQuery`) or traditional page-based pagination?
> 5. **CSAT Survey UI**: Should the customer portal include a post-resolution satisfaction survey form?
</artifacts>
</workspace_context>
<mission_brief>[Describe your task here...]</mission_brief>