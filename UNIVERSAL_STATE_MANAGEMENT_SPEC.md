# AI Agent UI & State Management Specification — Architectural Implementation

> **Role**: Senior UX Developer / Frontend Architect  
> **Scope**: Universal AI Agent & Application Interfaces (GIMXSOFT Platform)  
> **Core Constraint**: Zero-Regression Policy. Strict alignment with existing design tokens (`AppColors`, `DesignTokens`, `GlassCard`, `AppButton`) without altering baseline functional logic. Any state transition requiring destructive actions or behavioral modifications enforces explicit permission grants.  
> **Implementation Location**: `frontend/lib/core/states/universal/`  
> **Status**: Verified & Integrated  
> **Date**: November 2026  

---

## 1. Architectural Guardrails & UX Principles

### 1.1 Non-Destructive Integration Rule (Wrapper Pattern)
- **Slot / Container Pattern**: UI states are managed through `UniversalStateWrapper` declared over existing widgets. Core business logic, Riverpod providers, and event handlers are completely untouched.
- **Permission & Safety Interlocks**: Destructive actions (e.g. permanent member deletion, database resets) require `PermissionInterlockDialog` with explicit typed string confirmation (`"DELETE"` or resource identifier).
- **Telemetry & Accessibility**: Every state surfaces semantic accessibility attributes, `liveRegion` indicators, and keyboard navigation boundaries conforming to **WCAG 2.1 AA** standards.

### 1.2 Deterministic State Priority Queue
When multiple conditions occur concurrently (e.g. offline status while loading a new member form), `UniversalStatePriorityResolver` resolves them deterministically using a tiered priority queue:

$$\text{Critical Errors (Rank 100)} > \text{Network Outage (Rank 80)} > \text{Auth (Rank 60)} > \text{Transient Progress (Rank 40)} > \text{Data Views (Rank 20)}$$

---

## 2. Universal State Matrix (30 Core States) Implementation Map

| State ID | State Enum | Trigger & Conditions | Component Architecture | Behavioral UX Rule & Safeguard |
| :--- | :--- | :--- | :--- | :--- |
| **01** | `STATE_EMPTY` | Zero items; no user input | `AppEmptyState` with context icon | Guides user toward creation with zero-data callout. |
| **02** | `STATE_LOADING` | Initial async data fetch | `SkeletonLoader` / `InlineLoader` | Retains container geometry to avoid Layout Shift (CLS). |
| **03** | `STATE_REFRESHING` | Background re-fetching/polling | Top cyan micro-progress bar | Content stays visible and interactive; no skeleton swaps. |
| **04** | `STATE_SUCCESS` | Mutation/action completed | `AppToast` stack / checkmark pill | Auto-dismisses within $4000\text{ ms} \pm 500\text{ ms}$. In-place update. |
| **05** | `STATE_ERROR` | Fatal transaction failure | `ServerErrorView` with RFC 9457 | Masks internal stack traces; provides Correlation ID copy. |
| **06** | `STATE_WARNING` | Non-fatal threshold alert | Amber alert banner + warning icon | Non-blocking; does not disrupt adjacent UI workflows. |
| **07** | `STATE_PROCESSING` | Multi-step agent/async task | Semi-transparent overlay + spinner | Surfaces dynamic stage labels; responsive cancellation. |
| **08** | `STATE_NO_RESULTS` | Filter query returned 0 records | `SearchEmptyState` + Reset CTA | Retains search inputs and facets so user can adjust easily. |
| **09** | `STATE_NO_INTERNET` | Window offline event | `NetworkErrorView` + retry button | Disables network-bound buttons; queues local state. |
| **10** | `STATE_SLOW_NETWORK` | Request duration $>3000\text{ ms}$ | Non-intrusive warning header | Debounces taps to prevent redundant submission spam. |
| **11** | `STATE_OFFLINE_MODE` | User/system offline fallback | Top-right `Working Offline` badge | Marks non-syncable operations as disabled with tooltip. |
| **12** | `STATE_LOGIN_REQUIRED` | Guest hits protected resource | `UnauthorizedErrorView` | Preserves navigation path context and draft form inputs. |
| **13** | `STATE_SESSION_EXPIRED` | Auth token expired (HTTP 401) | In-place re-authentication modal | Preserves on-screen inputs without destructive redirects. |
| **14** | `STATE_PERMISSION_DENIED`| Lacks claims/role (HTTP 403) | `UnauthorizedErrorView` (Forbidden) | Clearly specifies missing role/claim (`GymOwner required`). |
| **15** | `STATE_FORM_VALIDATION` | Client validation failure | Microcopy under invalid inputs | Sets focus to first invalid input; retains entered data. |
| **16** | `STATE_UNSAVED_CHANGES` | Dirty form on navigation | `UnsavedChangesGuardDialog` | Prompts Discard, Save Draft, or Continue Editing. |
| **17** | `STATE_UPLOADING` | File payload transmission | Floating upload progress card | Drag-and-drop feedback, file size check, abort control. |
| **18** | `STATE_DOWNLOADING` | Report/artifact export | Floating download indicator | Background awareness; does not trap the active screen. |
| **19** | `STATE_FIRST_TIME_USER` | `onboarding_completed: false` | Dismissible walkthrough banner | Always includes explicit `Skip Tour` action. |
| **20** | `STATE_404_NOT_FOUND` | URI / resource ID not found | `NotFoundErrorView` | Friendly copy, search navigation, and return CTA. |
| **21** | `STATE_MAINTENANCE` | System maintenance (HTTP 503) | `MaintenanceTakeoverView` | Displays estimated downtime window & refresh button. |
| **22** | `STATE_ACCOUNT_VERIFICATION` | Email/phone verification gate | Persistent top banner | Non-blocking interstitial; allows exploration of open areas. |
| **23** | `STATE_FEATURE_RESTRICTED` | Feature gated by plan tier | `FeatureRestrictedView` | Demonstrates value proposition before upgrade CTA. |
| **24** | `STATE_DELETE_CONFIRMATION`| Destructive resource purge | `PermissionInterlockDialog` | Requires typed confirmation string (`"DELETE"`) to proceed. |
| **25** | `STATE_RATE_LIMITED` | HTTP 429 Too Many Requests | `RateLimitedCooldownView` | Live cooldown countdown (`Retry available in 42s`). |
| **26** | `STATE_SERVER_UNAVAILABLE`| Upstream crash (HTTP 502/504) | `ServerErrorView` | Exponential backoff auto-retry indicators. |
| **27** | `STATE_PARTIAL_SUCCESS` | Batch job subset failed | `PartialSuccessView` | Split progress bar + one-click `Retry Failed (N)`. |
| **28** | `STATE_SEARCH_STATE` | Search input active/focused | Dropdown suggestions + clear | 300ms debounce with full keyboard navigation ($↑$, $↓$, Enter). |
| **29** | `STATE_NOTIFICATION_STATE`| Unread messages/async alert | Notification bell + count pill | Grouped notifications, bulk `Mark all as read`. |
| **30** | `STATE_SYSTEM_UPDATE_AVAILABLE` | New app version detected | `SystemUpdatePill` banner | Non-modal bottom pill with `Reload Now` action. |

---

## 3. Permission & Action Safety Interlocks

### 3.1 Permission Safety Matrix
| Action Type | Mutation Severity | Default Permission Flow | Fallback Behavior |
| :--- | :--- | :--- | :--- |
| **Delete Confirmation** | High | Modal + Exact Typed String Confirmation | Abort operation and retain original state |
| **Session Expired** | Medium | In-place Re-authentication Modal | Cache current dirty inputs to local storage |
| **Feature Restricted** | Low | Inline Upgrade Prompt | Preserve view-only state |
| **Unsaved Changes** | Medium | Guard Interceptor Modal | Prevent route transition until decided |
| **Partial Success** | Low | User-selected Selective Retry | Preserve successful responses |

### 3.2 Code Example: Invoking Permission Interlock
```dart
final granted = await PermissionInterlockDialog.request(
  context: context,
  requirement: PermissionRequirement.destructiveDelete(
    resourceName: member.fullName,
    resourceIdentifier: member.memberCode,
  ),
);

if (granted) {
  await ref.read(membersProvider.notifier).deleteMember(member.id);
}
```

---

## 4. UniversalStateWrapper Usage Pattern

The `UniversalStateWrapper` wraps any existing feature widget cleanly:

```dart
UniversalStateWrapper(
  state: UniversalStatePriorityResolver.resolve(
    StateResolutionContext(
      httpStatusCode: asyncState.error != null ? 500 : null,
      isLoading: asyncState.isLoading,
      isEmpty: members.isEmpty,
    ),
  ),
  onRetry: () => ref.refresh(membersProvider),
  child: MembersTable(members: members),
)
```

---
*Maintained under GIMXSOFT Architecture Standards.*

