# Blood, Sweat & Boundaries — v1.0 prototype

## Run it
Open `index.html` in a modern browser. No build tools are required.

## Included in this prototype
- Responsive dashboard for desktop and mobile
- Tournament settings and private invite-code placeholder
- Sample international player pool plus add-player form
- 15-player squad selection
- 11-player match XI selection
- Captain and vice-captain validation
- Local browser persistence
- Sample leaderboard and demo-points simulator
- JSON export of the local league data
- Initial T20 scoring-rule display

## Important limitations
This is a front-end prototype, not yet a production multi-user service:
- Data is saved only in the browser's localStorage; different friends do not share data.
- Login, invitations, secure admin roles and hosted database are not connected.
- Player pool is illustrative and must be replaced/verified for the chosen tournament.
- Live scores and automated fantasy scoring are not connected to a cricket data provider.
- Strike-rate, economy-rate and wicket-haul bonus tiers need final rule confirmation and test cases before production.

## Production build plan
1. Supabase project: authentication, Postgres tables, row-level security, private league membership.
2. Tournament administration: tournament, franchises/countries, official player roster, match schedule, deadlines.
3. Fantasy rules engine: versioned scoring rules; batting, bowling, fielding, captain multipliers; idempotent score recalculation.
4. Cricket API adapter: provider selection, licensed API key stored server-side, polling/webhooks, score reconciliation.
5. Match locking: server-time lock at toss/first ball policy, immutable submitted lineups after lock.
6. Leaderboards: per-match, cumulative tournament, tie-breakers and audit log.
7. QA/security: duplicate event protection, API outage handling, admin audit trail, backups, mobile testing.
8. Deployment: Vercel/Netlify frontend + Supabase backend + custom domain.

## Initial scoring defaults shown
Run +1; four bonus +1; six bonus +2; wicket +25; bowled/LBW +8; catch +8; run out +12; stumping +16; maiden +16; player of match +20; captain 2x; vice-captain 1.5x.

## Additional implementation assets
- `schema.sql`: proposed relational schema for Supabase/Postgres (RLS policies intentionally require deployment-specific review).
- `scoring-rules.json`: draft T20 rules including the previously discussed strike-rate, economy and wicket-haul tiers.
