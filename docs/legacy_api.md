# Legacy API contract — Express (`backend/server.js`)

Captured 2026-08-19 as the **parity checklist** for the FastAPI rewrite.
Every row must end up either implemented in the new API or explicitly marked
`DROP` with a reason. Nothing gets carried forward by accident.

Base URL: `http://localhost:3000`.
Auth: `Authorization: Bearer <jwt>`. HS256, secret `JWT_SECRET`, `expiresIn: 8h`.

| Legend | Meaning |
|---|---|
| DEFECT | Known defect — see "Defects" below. Fixed by construction in the rewrite. |
| IDOR | Missing authorization check. Must gain an ownership guard. |

---

## 1. Page routes (no auth)

These disappear in the rewrite — the React SPA owns routing and Vite serves the
shell. Listed only so the URLs can be preserved as SPA redirects if desired.

| Method | Path | Serves |
|---|---|---|
| GET | `/` | `public/Landing_Page1.html` |
| GET | `/companyRegistration` | `public/company_register_test.html` |
| GET | `/candidateRegistration` | `public/candidate_registration.html` |
| GET | `/candidateLanding` | `private/candidate_landing_page.html` |
| GET | `/hrHomePage` | `private/HR_HomePage.html` |
| GET | `/feedback` | `private/feedback.html` |
| GET | `/interviewScheduler` | `private/interview_scheduler.html` |
| GET | `/candidateLogin` | DEFECT `public/candidate_login.html` — file does not exist (real file is `login.html`) |
| GET | `/candidateDashboard` | `public/candidate_dashboard.html` (declared twice; 2nd is dead code after the 404 handler) |
| GET | `/updateProfile` | `public/update_profile.html` |
| GET | `/viewApplications` | `public/candidate_applications.html` |
| GET | `/candidateSettings` | `public/candidate_settings.html` |
| GET | `/resumeManager` | `public/resume_manager.html` |
| GET | `/skillAssessment` | `public/skill_assessment.html` |
| GET | `/test` | text "Server is working" |

> The `frontend/private/` directory name is a convention only — these routes are
> unauthenticated and serve to anyone. Only the JSON APIs are token-gated.
> The rewrite gates these behind `ProtectedRoute` by role.

---

## 2. Health

| Method | Path | Auth | Notes |
|---|---|---|---|
| GET | `/api/db-status` | none | DEFECT Handler never sends a response — **the request hangs forever**. Replace with `/healthz` + `/readyz`. |

---

## 3. Auth & registration (no auth)

| Method | Path | Request | Response |
|---|---|---|---|
| POST | `/api/candidates/apply` | `multipart/form-data`: `fullname`, `email`, `phone`, `position`, `education`, `experience`, `skills`, `location`, `notes`, `password`, file `resume` | `{ message, id }` |
| POST | `/api/companies/apply` | `multipart/form-data`: `companyName`, `industry`, `regNo`, `gstin`, `officialEmail`, `website`, `contact`, `size`, `address`, `password`, file `logo` | `{ message, id }` |
| POST | `/api/auth/login` | `{ email, password }` | DEFECT `{ token, user: { id, email } }` — see Defect 1; `id`/`email` are `undefined` in practice |
| POST | `/api/companies/login` | `{ officialEmail, password }` | `{ message, token, company: { id, name, email } }` |

Rewrite notes: `fullname` is split on the first space into `first_name` /
`last_name` — replace with explicit first/last fields. `bcrypt.hash` is called
**before** the try block in both `apply` routes, so a missing `password` throws
an unhandled 500 rather than a 400.

---

## 4. Company API — `authenticateCompany`, `req.company = { companyId, email }`

| Method | Path | Notes |
|---|---|---|
| GET | `/api/companies?email=` | IDOR Any valid company token can read **any** company by email |
| GET | `/api/candidates` | Returns every candidate in the system, unpaginated; `status` and `appliedDate` are hardcoded stubs |
| GET | `/api/interviews` | Scoped to `req.company.companyId` — OK |
| POST | `/api/interviews` | DEFECT Spreads `req.body` into the insert — mass assignment. Needs an explicit schema. |
| PATCH | `/api/interviews/:id/status` | IDOR No ownership check — company A can mutate company B's interview |
| GET | `/api/interviews/for-feedback` | Completed interviews with no feedback yet — OK |
| POST | `/api/notes` | DEFECT Queries `company_notes`, **which does not exist in the database** — 500 at runtime |
| GET | `/api/notes` | DEFECT same |
| DELETE | `/api/notes/:id` | DEFECT same (is company-scoped in the SQL, at least) |
| POST | `/api/feedback` | Writes `interview_feedback` — OK |
| GET | `/api/feedback` | Scoped to company — OK |
| GET | `/api/feedback/candidate/:candidateId` | IDOR No ownership check |

---

## 5. Candidate API — `authenticateCandidate`, `req.candidate = { userId, email }`

DEFECT: this middleware accepts the token from the **`?token=` query string** as
well as the header (used for inline resume viewing). Tokens leak into server
logs, browser history, and `Referer` headers. The rewrite uses a separate
single-use signed URL instead.

| Method | Path | Notes |
|---|---|---|
| GET | `/api/candidate/profile` | |
| PUT | `/api/candidate/profile` | Whitelisted `SET` clause — safe from injection |
| GET | `/api/candidate/interviews` | |
| GET | `/api/candidate/feedback` | |
| GET | `/api/candidate/applications` | DEFECT Fabricates mock pipeline stages; hardcodes `'Full-time'` |
| PATCH | `/api/candidate/applications/:id/withdraw` | |
| GET | `/api/candidate/resume` | Metadata |
| POST | `/api/candidate/resume/upload` | `multipart`, field `resume`. DEFECT No MIME filter, no size limit |
| GET | `/api/candidate/resume/download` | Attachment |
| GET | `/api/candidate/resume/view` | Inline |
| GET | `/api/candidate/resume/view-url` | DEFECT Claims a 2-minute token; actually mints an **8-hour** token with `userId: undefined` (Defect 5) |
| POST | `/api/candidate/change-password` | `{ currentPassword, newPassword }`; verifies then bcrypt-hashes — OK |

---

## 6. Assessments — `authenticateCandidate`

| Method | Path | Notes |
|---|---|---|
| GET | `/api/assessments` | Catalog + this candidate's progress |
| POST | `/api/assessments/:id/start` | Returns questions. Verify `correct_answer` is not leaked to the client |
| POST | `/api/assessments/:id/submit` | `{ answers[], timeTaken }` → score, pass/fail, badge award |
| GET | `/api/assessments/stats` | |
| GET | `/api/assessments/badges` | |
| GET | `/api/assessments/recent-results` | |

Scoring and badge-award logic currently lives inside `db.js` query functions;
it moves to `app/services/scoring.py` and `app/services/badges.py`.

---

## 7. Called by the frontend but never implemented — decide per row

| Path | Called from | Decision |
|---|---|---|
| `GET /api/activities` | `public/candidate_landing_page.js` | TODO: build or drop |
| `GET /api/candidate/resume/history/:i` | `public/resume_manager.html` | TODO: build or drop |
| `POST /api/candidate/resume/restore/:i` | `public/resume_manager.html` | TODO: build or drop |

The resume-history UI is fully built in the HTML and silently fails. Either
implement resume versioning in Phase 3 §5 or remove the UI in Phase 4.

---

## Defects to fix by construction

1. **`server.js:210`** — `const [rows] = await db.verifyCandidate(...)` destructures
   the *array of rows* as if it were the array itself. `rows` becomes the first
   row object, so `rows.length` is `undefined` (never `0`, so the 401 branch is
   unreachable), `generateToken(rows)` receives the wrong shape, and the issued
   JWT carries `userId: undefined`. An unknown email throws a 500 instead of 401.
2. **`db.js:9`** — read `DB_PASS` while `.env` defines `DB_PASSWORD`; the password
   silently fell back to hardcoded `'root'`. *(Fixed in Phase 0.)*
3. **`db.js`** — three competing `module.exports = {...}` blocks (lines 331, 422,
   583). Only the last wins; `getCompanyPositions`, `getCompanyEmployees`, and
   `getAllRounds` are defined but unreachable.
4. **`server.js:24`** — `express.static(path.join("../frontend", 'public'))` uses a
   path relative to `process.cwd()`, so static assets 404 unless the server is
   started from inside `backend/`. Every other path correctly uses `__dirname`.
5. **`server.js:710`** — `generateToken({ candidateId }, "2m")`: `generateToken` is
   declared twice (lines 462, 471) and the winning version ignores a second
   argument, so the "2-minute" URL token lasts 8 hours with an undefined subject.
6. **Token storage** — the frontend uses three localStorage keys (`token`,
   `candidateToken`, `companyToken`); `resume_manager.html:731` reads a different
   key than the rest of that same file.
7. **`backend/backend_server.js`** — a dead 675-line Express 4 server. It requires
   `bcryptjs`, which is not in `package.json`, so it crashes on start. Delete.
8. **`backend/middleware/auth.js`** — never imported, and defaults `JWT_SECRET` to
   the hardcoded string `'supersecretkey'`. Delete.
9. **`backend/package.json`** — no `scripts`, no `name`, no `main`. The intended
   scripts live in the unused `backend/package_json.json`, whose Express 4 pin
   contradicts the installed Express 5.

## Schema drift (resolved in Phase 0)

`recruitment_system.sql` was a stale dump missing 7 tables the app queries and
containing real personal data. It has been regenerated from the live database
with synthetic seed data. The raw schema-only capture is
`docs/legacy_schema_actual.sql`.

The live `interviews` table is **fully denormalized** — `candidate_name`,
`position`, `round`, `interviewer_1..3` are free-text strings, not the foreign
keys the old dump described. Phase 1 normalizes this and replaces the
three-interviewer cap with an `interview_interviewers` join table.

`company_notes` exists in **neither** the dump nor the live database, so the
entire notes feature is dead at runtime.

## Live row counts at capture time

| Table | Rows |
|---|---|
| assessments | 5 |
| assessment_questions | 3 |
| badges | 5 |
| candidates | 1 |
| interviews | 2 |
| all others (companies, employees, positions, departments, rounds, auth_users, availability_slots, interview_feedback, candidate_assessment_results, candidate_badges) | 0 |

The database is essentially empty, so the Phase 1 ETL
(`scripts/migrate_from_mysql.py`) has almost nothing to carry over. Treat the
Postgres schema as a greenfield design rather than a constrained migration.
